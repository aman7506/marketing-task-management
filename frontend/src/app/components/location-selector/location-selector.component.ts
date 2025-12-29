import { Component, OnInit, Input, Output, EventEmitter, forwardRef } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { LocationHierarchyService, LocationOption, PincodeOption } from '../../services/location-hierarchy.service';

export interface LocationSelection {
    stateId: number | null;
    stateName: string | null;
    cityId: number | null;
    cityName: string | null;
    localityId: number | null;
    localityName: string | null;
    pincodeId: number | null;
    pincodeValue: string | null;
}

@Component({
    selector: 'app-location-selector',
    templateUrl: './location-selector.component.html',
    styleUrls: ['./location-selector.component.css'],
    providers: [
        {
            provide: NG_VALUE_ACCESSOR,
            useExisting: forwardRef(() => LocationSelectorComponent),
            multi: true
        }
    ]
})
export class LocationSelectorComponent implements OnInit, ControlValueAccessor {
    @Input() required: boolean = false;
    @Output() locationChange = new EventEmitter<LocationSelection>();

    locationForm!: FormGroup;

    states: LocationOption[] = [];
    cities: LocationOption[] = [];
    localities: LocationOption[] = [];
    pincodes: PincodeOption[] = [];

    loading = {
        states: false,
        cities: false,
        localities: false,
        pincodes: false
    };

    private onChange: any = () => { };
    private onTouched: any = () => { };

    constructor(
        private fb: FormBuilder,
        private locationService: LocationHierarchyService
    ) {
        this.initForm();
    }

    ngOnInit(): void {
        this.loadStates();
        this.setupFormListeners();
    }

    private initForm(): void {
        this.locationForm = this.fb.group({
            stateId: [null, this.required ? Validators.required : null],
            cityId: [{ value: null, disabled: true }, this.required ? Validators.required : null],
            localityId: [{ value: null, disabled: true }, this.required ? Validators.required : null],
            pincodeId: [{ value: null, disabled: true }, this.required ? Validators.required : null]
        });
    }

    private setupFormListeners(): void {
        this.locationForm.valueChanges.subscribe(() => {
            const selection = this.getLocationSelection();
            this.onChange(selection);
            this.locationChange.emit(selection);
        });
    }

    private getLocationSelection(): LocationSelection {
        const stateId = this.locationForm.get('stateId')?.value;
        const cityId = this.locationForm.get('cityId')?.value;
        const localityId = this.locationForm.get('localityId')?.value;
        const pincodeId = this.locationForm.get('pincodeId')?.value;

        const state = this.states.find(s => s.id === stateId);
        const city = this.cities.find(c => c.id === cityId);
        const locality = this.localities.find(l => l.id === localityId);
        const pincode = this.pincodes.find(p => p.id === pincodeId);

        return {
            stateId: stateId || null,
            stateName: state?.name || null,
            cityId: cityId || null,
            cityName: city?.name || null,
            localityId: localityId || null,
            localityName: locality?.name || null,
            pincodeId: pincodeId || null,
            pincodeValue: pincode?.value || null
        };
    }

    loadStates(): void {
        this.loading.states = true;
        this.locationService.getStates().subscribe({
            next: (states) => {
                this.states = states;
                this.loading.states = false;
            },
            error: (err) => {
                console.error('Error loading states:', err);
                this.loading.states = false;
            }
        });
    }

    onStateChange(stateId: number): void {
        if (!stateId) {
            this.resetCascade(['cityId', 'localityId', 'pincodeId']);
            return;
        }

        this.loading.cities = true;
        this.locationService.getCitiesByState(stateId).subscribe({
            next: (cities) => {
                this.cities = cities;
                this.locationForm.get('cityId')?.enable();
                this.resetCascade(['localityId', 'pincodeId']);
                this.loading.cities = false;
            },
            error: (err) => {
                console.error('Error loading cities:', err);
                this.loading.cities = false;
            }
        });
    }

    onCityChange(cityId: number): void {
        if (!cityId) {
            this.resetCascade(['localityId', 'pincodeId']);
            return;
        }

        this.loading.localities = true;
        this.locationService.getLocalitiesByCity(cityId).subscribe({
            next: (localities) => {
                this.localities = localities;
                this.locationForm.get('localityId')?.enable();
                this.resetCascade(['pincodeId']);
                this.loading.localities = false;
            },
            error: (err) => {
                console.error('Error loading localities:', err);
                this.loading.localities = false;
            }
        });
    }

    onLocalityChange(localityId: number): void {
        if (!localityId) {
            this.resetCascade(['pincodeId']);
            return;
        }

        this.loading.pincodes = true;
        this.locationService.getPincodesByLocality(localityId).subscribe({
            next: (pincodes) => {
                this.pincodes = pincodes;
                this.locationForm.get('pincodeId')?.enable();
                this.loading.pincodes = false;
            },
            error: (err) => {
                console.error('Error loading pincodes:', err);
                this.loading.pincodes = false;
            }
        });
    }

    private resetCascade(fields: string[]): void {
        fields.forEach(field => {
            this.locationForm.get(field)?.setValue(null);
            this.locationForm.get(field)?.disable();
        });

        if (fields.includes('cityId')) {
            this.cities = [];
        }
        if (fields.includes('localityId')) {
            this.localities = [];
        }
        if (fields.includes('pincodeId')) {
            this.pincodes = [];
        }
    }

    // ControlValueAccessor implementation
    writeValue(value: any): void {
        if (value) {
            this.locationForm.patchValue(value, { emitEvent: false });
        }
    }

    registerOnChange(fn: any): void {
        this.onChange = fn;
    }

    registerOnTouched(fn: any): void {
        this.onTouched = fn;
    }

    setDisabledState(isDisabled: boolean): void {
        isDisabled ? this.locationForm.disable() : this.locationForm.enable();
    }
}
