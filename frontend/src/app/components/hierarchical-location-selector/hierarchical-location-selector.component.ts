import { Component, OnInit, Input, Output, EventEmitter, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR, FormsModule } from '@angular/forms';
import { LocationService } from '../../services/location.service';
import { State, City, Area, Pincode } from '../../models/location.models';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs/operators';
import { Subject, of } from 'rxjs';
import { CommonModule } from '@angular/common';

export interface HierarchicalLocationSelection {
  stateId?: number;
  stateName?: string;
  cityId?: number;
  cityName?: string;
  areaIds?: number[];
  areaNames?: string[];
  pincodeId?: number;
  pincodeValue?: string;
  localityName?: string;
}

@Component({
  selector: 'app-hierarchical-location-selector',
  templateUrl: './hierarchical-location-selector.component.html',
  styleUrls: ['./hierarchical-location-selector.component.css'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => HierarchicalLocationSelectorComponent),
      multi: true
    }
  ]
})
export class HierarchicalLocationSelectorComponent implements OnInit, ControlValueAccessor {
  @Input() allowMultipleAreas = true;
  @Input() autoSelectDelhi = true;
  @Input() required = false; 
  @Input() disabled = false;
  @Output() selectionChange = new EventEmitter<HierarchicalLocationSelection>();

  // Data arrays
  states: State[] = [];
  areas: Area[] = [];
  cities: City[] = [];
  pincodes: Pincode[] = [];

  // Filtered arrays for search
  filteredStates: State[] = [];
  filteredAreas: Area[] = [];
  filteredCities: City[] = [];
  filteredPincodes: Pincode[] = [];

  // Selected values
  selectedState: State | null = null;
  selectedCity: City | null = null;
  selectedAreas: Area[] = [];
  selectedPincode: Pincode | null = null;

  // Search terms
  stateSearchTerm = '';
  areaSearchTerm = '';
  citySearchTerm = '';
  pincodeSearchTerm = '';

  // Search subjects for debouncing
  private stateSearchSubject = new Subject<string>();
  private areaSearchSubject = new Subject<string>();
  private citySearchSubject = new Subject<string>();
  private pincodeSearchSubject = new Subject<string>();

  // Loading states
  isLoadingStates = false;
  isLoadingAreas = false;
  isLoadingPincodes = false;

  // Dropdown visibility
  showStateDropdown = false;
  showAreaDropdown = false;
  showPincodeDropdown = false;
  showCityDropdown = false;

  // ControlValueAccessor
  private onChange = (value: HierarchicalLocationSelection) => {};
  private onTouched = () => {};

  constructor(private locationService: LocationService) {}

  ngOnInit() {
    this.loadStates();
    this.setupSearchSubscriptions();
  }

  // ControlValueAccessor implementation
  writeValue(value: HierarchicalLocationSelection): void {
    if (value) {
      this.setInitialSelection(value);
    }
  }

  registerOnChange(fn: (value: HierarchicalLocationSelection) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  private setInitialSelection(value: HierarchicalLocationSelection) {
    if (value.stateId) {
      this.loadStates().then(() => {
        this.selectedState = this.states.find(s => s.id === value.stateId) || null;
        if (this.selectedState) {
          this.onStateSelect(this.selectedState, false);

          const loadCityThenAreas = async () => {
            if (value.cityId) {
              await this.loadCities(this.selectedState!.id);
              this.selectedCity = this.cities.find(c => c.id === value.cityId) || null;
              if (this.selectedCity) {
                await this.loadAreasByCity(this.selectedCity.id);
              } else {
                await this.loadAreas(this.selectedState!.id);
              }
            } else {
              await this.loadCities(this.selectedState!.id);
              await this.loadAreas(this.selectedState!.id);
            }
          };

          loadCityThenAreas().then(async () => {
            if (value.areaIds && value.areaIds.length > 0) {
              this.selectedAreas = this.areas.filter(a => value.areaIds!.includes(a.id));
              this.filteredAreas = [...this.areas];

              if (value.pincodeId && this.selectedAreas.length > 0) {
                await this.loadPincodes(this.selectedAreas[0].id);
                this.selectedPincode = this.pincodes.find(p => p.id === value.pincodeId) || null;
                this.filteredPincodes = [...this.pincodes];
              }
            }
          });
        }
      });
    }
  }

  private setupSearchSubscriptions() {
    // State search
    this.stateSearchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(term => {
        if (!term.trim()) {
          return of(this.states);
        }
        return this.locationService.searchStates(term);
      })
    ).subscribe(states => {
      this.filteredStates = states;
    });

    // Area search
    this.areaSearchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(term => {
        if (!term.trim()) {
          return of(this.areas);
        }
        return this.locationService.searchAreas(term, this.selectedState?.id, this.selectedCity?.id);
      })
    ).subscribe(areas => {
      this.filteredAreas = areas;
    });

    // City search
    this.citySearchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(term => {
        if (!term.trim()) {
          return of(this.cities);
        }
        return this.locationService.searchCities(term, this.selectedState?.id);
      })
    ).subscribe(cities => {
      this.filteredCities = cities;
    });

    // Pincode search
    this.pincodeSearchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(term => {
        if (!term.trim()) {
          return of(this.pincodes);
        }
        const id = this.selectedAreas.length > 0 ? this.selectedAreas[0].id : undefined;
        return this.locationService.searchPincodes(term, id);
      })
    ).subscribe(pincodes => {
      this.filteredPincodes = pincodes;
    });
  }

  private async loadStates(): Promise<void> {
    this.isLoadingStates = true;
    try {
      this.states = await this.locationService.getAllStates().toPromise() || [];
      this.filteredStates = [...this.states];
      
      // Auto-select Delhi if enabled
      if (this.autoSelectDelhi && !this.selectedState) {
        const delhi = this.states.find(s => s.name.toLowerCase().includes('delhi'));
        if (delhi) {
          this.selectedState = delhi;
          this.onStateSelect(delhi, false);
        }
      }
    } catch (error) {
      console.error('Error loading states:', error);
    } finally {
      this.isLoadingStates = false;
    }
  }

  private async loadAreas(id: number): Promise<void> {
    this.isLoadingAreas = true;
    try {
      this.areas = await this.locationService.getAreasByState(id).toPromise() || [];
      this.filteredAreas = [...this.areas];
    } catch (error) {
      console.error('Error loading areas:', error);
    } finally {
      this.isLoadingAreas = false;
    }
  }

  private async loadCities(id: number): Promise<void> {
    try {
      this.cities = await this.locationService.getCitiesByState(id).toPromise() || [];
      this.filteredCities = [...this.cities];
    } catch (error) {
      console.error('Error loading cities:', error);
    }
  }

  private async loadAreasByCity(id: number): Promise<void> {
    this.isLoadingAreas = true;
    try {
      // Filter existing areas for city if present in mock, otherwise fallback by state
      const allAreas = await this.locationService.getAreasByState(this.selectedState!.id).toPromise() || [];
      this.areas = allAreas.filter(a => a.id === id || !a.id);
      this.filteredAreas = [...this.areas];
    } catch (error) {
      console.error('Error loading areas by city:', error);
    } finally {
      this.isLoadingAreas = false;
    }
  }

  private async loadPincodes(id: number): Promise<void> {
    this.isLoadingPincodes = true;
    try {
      this.pincodes = await this.locationService.getPincodesByArea(id).toPromise() || [];
      this.filteredPincodes = [...this.pincodes];
    } catch (error) {
      console.error('Error loading pincodes:', error);
    } finally {
      this.isLoadingPincodes = false;
    }
  }

  // Search methods
  onStateSearch(term: string) {
    this.stateSearchTerm = term;
    this.stateSearchSubject.next(term);
  }

  onAreaSearch(term: string) {
    this.areaSearchTerm = term;
    this.areaSearchSubject.next(term);
  }

  onCitySearch(term: string) {
    this.citySearchTerm = term;
    this.citySearchSubject.next(term);
  }

  onPincodeSearch(term: string) {
    this.pincodeSearchTerm = term;
    this.pincodeSearchSubject.next(term);
  }

  // Selection methods
  onStateSelect(state: State, emitChange = true) {
    this.selectedState = state;
    this.selectedCity = null;
    this.selectedAreas = [];
    this.selectedPincode = null;
    this.stateSearchTerm = state.name;
    this.citySearchTerm = '';
    this.areaSearchTerm = '';
    this.pincodeSearchTerm = '';
    this.showStateDropdown = false;
    
    this.loadCities(state.id);
    this.loadAreas(state.id);
    
    if (emitChange) {
      this.emitSelectionChange();
    }
  }

  onCitySelect(city: City) {
    this.selectedCity = city;
    this.citySearchTerm = city.name;
    this.showCityDropdown = false;
    this.selectedAreas = [];
    this.selectedPincode = null;
    this.pincodeSearchTerm = '';
    this.loadAreasByCity(city.id);
    this.emitSelectionChange();
  }

  onAreaSelect(area: Area) {
    if (this.allowMultipleAreas) {
      const index = this.selectedAreas.findIndex(a => a.id === area.id);
      if (index > -1) {
        this.selectedAreas.splice(index, 1);
      } else {
        this.selectedAreas.push(area);
      }
    } else {
      this.selectedAreas = [area];
      this.showAreaDropdown = false;
    }
    
    this.selectedPincode = null;
    this.pincodeSearchTerm = '';
    
    if (this.selectedAreas.length > 0) {
      this.loadPincodes(this.selectedAreas[0].id);
    }
    
    this.emitSelectionChange();
  }

  onPincodeSelect(pincode: Pincode) {
    this.selectedPincode = pincode;
    this.pincodeSearchTerm = `${pincode.value} - ${pincode.localityName || ''}`;
    this.showPincodeDropdown = false;
    
    this.emitSelectionChange();
  }

  // Remove selections
  removeArea(area: Area) {
    const index = this.selectedAreas.findIndex(a => a.id === area.id);
    if (index > -1) {
      this.selectedAreas.splice(index, 1);
      this.emitSelectionChange();
    }
  }

  clearState() {
    this.selectedState = null;
    this.selectedAreas = [];
    this.selectedPincode = null;
    this.stateSearchTerm = '';
    this.areaSearchTerm = '';
    this.pincodeSearchTerm = '';
    this.areas = [];
    this.pincodes = [];
    this.filteredAreas = [];
    this.filteredPincodes = [];
    this.emitSelectionChange();
  }

  clearPincode() {
    this.selectedPincode = null;
    this.pincodeSearchTerm = '';
    this.emitSelectionChange();
  }

  clearAreas() {
    this.selectedAreas = [];
    this.selectedPincode = null;
    this.areaSearchTerm = '';
    this.pincodeSearchTerm = '';
    this.pincodes = [];
    this.filteredPincodes = [];
    this.emitSelectionChange();
  }

  // Dropdown visibility
  toggleStateDropdown() {
    if (this.disabled) return;
    this.showStateDropdown = !this.showStateDropdown;
    this.showAreaDropdown = false;
    this.showPincodeDropdown = false;
  }

  toggleAreaDropdown() {
    if (this.disabled || !this.selectedState) return;
    this.showAreaDropdown = !this.showAreaDropdown;
    this.showStateDropdown = false;
    this.showPincodeDropdown = false;
  }

  togglePincodeDropdown() {
    if (this.disabled || this.selectedAreas.length === 0) return;
    this.showPincodeDropdown = !this.showPincodeDropdown;
    this.showStateDropdown = false;
    this.showAreaDropdown = false;
  }

  // Utility methods
  isAreaSelected(area: Area): boolean {
    return this.selectedAreas.some(a => a.id === area.id);
  }

  getSelectedAreasText(): string {
    if (this.selectedAreas.length === 0) return 'Select areas';
    if (this.selectedAreas.length === 1) return this.selectedAreas[0].name;
    return `${this.selectedAreas.length} areas selected`;
  }

  getSelectedAreaNames(): string {
    return this.selectedAreas.map(a => a.name).join(', ');
  }

  private emitSelectionChange() {
    const selection: HierarchicalLocationSelection = {
      stateId: this.selectedState?.id,
      stateName: this.selectedState?.name,
      cityId: this.selectedCity?.id,
      cityName: this.selectedCity?.name,
      areaIds: this.selectedAreas.map(a => a.id),
      areaNames: this.selectedAreas.map(a => a.name),
      pincodeId: this.selectedPincode?.id,
      pincodeValue: this.selectedPincode?.value,
      localityName: this.selectedPincode?.localityName
    };

    this.selectionChange.emit(selection);
    this.onChange(selection);
    this.onTouched();
  }

  // Click outside to close dropdowns
  onDocumentClick(event: Event) {
    const target = event.target as HTMLElement;
    if (!target.closest('.hierarchical-location-selector')) {
      this.showStateDropdown = false;
      this.showAreaDropdown = false;
      this.showPincodeDropdown = false;
    }
  }
}