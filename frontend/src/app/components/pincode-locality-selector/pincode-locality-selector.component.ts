import { Component, OnInit, Input, Output, EventEmitter, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { PincodeService, PincodeLocality } from '../../services/pincode.service';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

export interface PincodeLocalitySelection {
  pincode: string;
  localityName: string;
  pincodeId?: number;
  areaId?: number;
}

@Component({
  selector: 'app-pincode-locality-selector',
  templateUrl: './pincode-locality-selector.component.html',
  styleUrls: ['./pincode-locality-selector.component.css'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => PincodeLocalitySelectorComponent),
      multi: true
    }
  ]
})
export class PincodeLocalitySelectorComponent implements OnInit, ControlValueAccessor {
  @Input() required = false;
  @Input() disabled = false;
  @Output() selectionChange = new EventEmitter<PincodeLocalitySelection>();

  form: FormGroup;
  pincodes: string[] = [];
  localities: string[] = [];
  allPincodeLocalities: PincodeLocality[] = [];
  filteredPincodes: string[] = [];
  filteredLocalities: string[] = [];
  isLoadingPincodes = false;
  isLoadingLocalities = false;
  
  // Dropdown visibility
  showPincodeDropdown = false;
  showLocalityDropdown = false;
  
  // Search terms
  pincodeSearchTerm = '';
  localitySearchTerm = '';
  
  // ControlValueAccessor
  private onChange = (value: PincodeLocalitySelection) => {};
  private onTouched = () => {};

  constructor(
    private fb: FormBuilder,
    private pincodeService: PincodeService
  ) {
    this.form = this.fb.group({
      pincode: ['', this.required ? Validators.required : null],
      localityName: ['', this.required ? Validators.required : null]
    });
    
    // Subscribe to form changes
    this.form.get('pincode')?.valueChanges.pipe(
      debounceTime(300),
      distinctUntilChanged()
    ).subscribe(value => {
      if (value) {
        this.loadLocalitiesForPincode(value);
        this.form.get('localityName')?.setValue('');
        this.emitChange();
      }
    });
    
    this.form.get('localityName')?.valueChanges.pipe(
      debounceTime(300),
      distinctUntilChanged()
    ).subscribe(() => {
      this.emitChange();
    });
  }

  ngOnInit(): void {
    this.loadPincodes();
    this.loadAllPincodeLocalities();
  }
  
  // ControlValueAccessor implementation
  writeValue(value: PincodeLocalitySelection): void {
    if (value) {
      this.form.patchValue({
        pincode: value.pincode,
        localityName: value.localityName
      }, { emitEvent: false });
      
      if (value.pincode) {
        this.loadLocalitiesForPincode(value.pincode);
      }
    }
  }
  
  registerOnChange(fn: (value: PincodeLocalitySelection) => void): void {
    this.onChange = fn;
  }
  
  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }
  
  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
    if (isDisabled) {
      this.form.disable();
    } else {
      this.form.enable();
    }
  }
  
  // Load data methods
  loadPincodes(): void {
    this.isLoadingPincodes = true;
    this.pincodeService.getPincodes().subscribe(
      data => {
        this.pincodes = data.map(item => item.pincode);
        this.filteredPincodes = [...this.pincodes];
        this.isLoadingPincodes = false;
      },
      error => {
        console.error('Error loading pincodes:', error);
        this.isLoadingPincodes = false;
      }
    );
  }
  
  loadAllPincodeLocalities(): void {
    this.pincodeService.getPincodeLocalities().subscribe(
      data => {
        this.allPincodeLocalities = data;
      },
      error => {
        console.error('Error loading all pincode-localities:', error);
      }
    );
  }
  
  loadLocalitiesForPincode(pincode: string): void {
    this.isLoadingLocalities = true;
    this.pincodeService.getLocalitiesByPincode(pincode).subscribe(
      data => {
        this.localities = data;
        this.filteredLocalities = [...this.localities];
        this.isLoadingLocalities = false;
      },
      error => {
        console.error('Error loading localities for pincode:', error);
        this.isLoadingLocalities = false;
      }
    );
  }
  
  // Search methods
  onPincodeSearch(term: string): void {
    this.pincodeSearchTerm = term;
    this.filteredPincodes = this.pincodes.filter(
      p => p.toLowerCase().includes(term.toLowerCase())
    );
  }
  
  onLocalitySearch(term: string): void {
    this.localitySearchTerm = term;
    this.filteredLocalities = this.localities.filter(
      l => l.toLowerCase().includes(term.toLowerCase())
    );
  }
  
  // Selection methods
  onPincodeSelect(pincode: string): void {
    this.form.get('pincode')?.setValue(pincode);
    this.showPincodeDropdown = false;
  }
  
  onLocalitySelect(locality: string): void {
    this.form.get('localityName')?.setValue(locality);
    this.showLocalityDropdown = false;
  }
  
  // Dropdown visibility
  togglePincodeDropdown(): void {
    if (this.disabled) return;
    this.showPincodeDropdown = !this.showPincodeDropdown;
    this.showLocalityDropdown = false;
  }
  
  toggleLocalityDropdown(): void {
    if (this.disabled || !this.form.get('pincode')?.value) return;
    this.showLocalityDropdown = !this.showLocalityDropdown;
    this.showPincodeDropdown = false;
  }
  
  // Clear methods
  clearPincode(): void {
    this.form.get('pincode')?.setValue('');
    this.form.get('localityName')?.setValue('');
    this.localities = [];
    this.filteredLocalities = [];
  }
  
  clearLocality(): void {
    this.form.get('localityName')?.setValue('');
  }
  
  // Emit change
  private emitChange(): void {
    if (this.form.valid) {
      const pincode = this.form.get('pincode')?.value;
      const localityName = this.form.get('localityName')?.value;
      
      if (pincode && localityName) {
        // Find the matching pincode-locality to get IDs
        const match = this.allPincodeLocalities.find(
          pl => pl.pincode === pincode && pl.locality_name === localityName
        );
        
        const selection: PincodeLocalitySelection = {
          pincode,
          localityName,
          pincodeId: match?.pincodeId,
          areaId: match?.areaId
        };
        
        this.onChange(selection);
        this.selectionChange.emit(selection);
      }
    }
    this.onTouched();
  }
}