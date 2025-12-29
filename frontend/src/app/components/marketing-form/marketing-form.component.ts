import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { EmployeeService } from '../../services/employee.service';
import { LocationService } from '../../services/location.service';
import { LocationHierarchyService, LocationOption, PincodeOption } from '../../services/location-hierarchy.service';
import { TaskService } from '../../services/task.service';
import { NotificationService } from '../../services/notification.service';
import { MarketingFormService, MarketingCampaignData } from '../../services/marketing-form.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-marketing-form',
  templateUrl: './marketing-form.component.html',
  styleUrls: [
    './marketing-form.component.css',
    './dropdown-styles.css'
  ]
})
export class MarketingFormComponent implements OnInit {
  marketingForm: FormGroup;
  isLoading = false;
  showSuccess = false;
  successMessage = '';
  errorMessage = '';

  // Task types
  taskTypes: any[] = [];
  selectedTaskTypes: number[] = [];

  // Location data
  states: any[] = [];
  cities: any[] = [];
  localities: any[] = [];
  filteredLocalities: any[] = [];
  pincodes: any[] = [];
  filteredPincodes: any[] = [];
  allPincodeData: any[] = [];
  selectedStateId: number | null = null;
  selectedCityId: number | null = null;
  selectedLocalityName: string | null = null;
  selectedLocalityId: number | null = null;  // ⭐ ADD: Track selected locality ID
  selectedPincodeId: number | null = null;   // ⭐ ADD: Track selected pincode ID

  // Searchable dropdown properties
  showLocalityDropdown = false;
  highlightedIndex = -1;
  showPincodeDropdown = false;
  highlightedPincodeIndex = -1;
  isClickingOnDropdown = false;

  // Manual location entry toggle
  useManualEntry = false;

  // ⭐ NEW: Admin-task-modal style location properties
  manualLocationEntry = false;
  pincodeOptions: string[] = [];
  localitySuggestions: string[] = [];


  constructor(
    private fb: FormBuilder,
    private router: Router,
    private locationService: LocationService,
    private locationHierarchyService: LocationHierarchyService,
    private taskService: TaskService,
    private notificationService: NotificationService,
    private marketingFormService: MarketingFormService,
    private cdr: ChangeDetectorRef
  ) {
    this.marketingForm = this.fb.group({
      campaignManager: ['', Validators.required],
      employeeCode: [''],
      taskDescription: ['', [Validators.required, Validators.minLength(10)]],
      taskDate: ['', Validators.required],
      deadline: ['', Validators.required],
      priority: ['Medium', Validators.required],

      // Location fields
      state: ['', Validators.required],
      city: ['', Validators.required],
      locality: ['', Validators.required],
      pincode: ['', Validators.required],
      customLocation: [''], // Manual location entry

      // Marketing specific fields
      clientName: [''],
      projectCode: [''],
      consultantName: [''],
      campCode: [''],
      estimatedHours: [''],
      additionalNotes: [''],
      consultantFeedback: [''],
      isUrgent: [false],

      // Marketing campaign fields
      expectedReach: [''],
      conversionGoal: [''],
      kpis: [''],
      marketingMaterials: [''],
      approvalRequired: [true],
      approvalContact: [''],
      budgetCode: [''],
      departmentCode: ['MKT']
    });
  }

  ngOnInit() {
    // ⭐ AUTO-GENERATE CAMPAIGN CODE ON LOAD
    this.loadNewCampaignCode();

    // Initialize current date/time once
    this.updateCurrentDateTime();
    // Update every minute instead of every second to avoid change detection issues
    setInterval(() => {
      this.updateCurrentDateTime();
      if (this.cdr) {
        this.cdr.detectChanges();
      }
    }, 60000); // Update every minute

    // Initialize with fallback data
    this.initializeTaskTypes();
    this.loadStates();

    // Check for edit mode from query params
    this.checkForEditMode();

    // Enable all fields by default
    this.marketingForm.get('locality')?.enable();
    this.marketingForm.get('pincode')?.enable();
    this.marketingForm.get('city')?.enable();
    this.marketingForm.get('state')?.enable();
  }

  // ⭐ LOAD AUTO-GENERATED CAMPAIGN CODE
  loadNewCampaignCode() {
    console.log('Loading new campaign code from backend...');
    this.marketingFormService.getNewCampaignCode().subscribe({
      next: (response) => {
        if (response.success && response['campaignCode']) {
          const newCode = response['campaignCode'];
          console.log('✅ Campaign code generated:', newCode);

          // Set the campaign code in the form
          this.marketingForm.patchValue({ campCode: newCode });

          // Disable the field to prevent manual editing
          this.marketingForm.get('campCode')?.disable();
        } else {
          console.error('Failed to generate campaign code:', response.message);
        }
      },
      error: (error) => {
        console.error('Error generating campaign code:', error);
      }
    });
  }

  checkForEditMode() {
    // Use state-based navigation data if present
    const navigation = this.router.getCurrentNavigation();
    const stateData = navigation && navigation.extras && navigation.extras.state && navigation.extras.state['campaignData'];
    if (stateData) {
      this.populateFormForEditing(stateData);
      return;
    }

    // Otherwise try fetching by campaignId from query param if mode=edit
    this.router.routerState.root.queryParams.subscribe(params => {
      if (params['mode'] === 'edit' && params['campaignId']) {
        // Fetch data from API using campaignId for consistent prefill
        const campaignId = params['campaignId'];
        this.marketingFormService.getMarketingCampaignById(campaignId).subscribe({
          next: (response) => {
            if (response.success && response.data) {
              this.populateFormForEditing(response.data);
            }
          },
          error: (error) => {
            console.error('Error fetching campaign data for edit:', error);
          }
        });
      } else if (params['campaignData']) {
        try {
          const campaignData = JSON.parse(params['campaignData']);
          this.populateFormForEditing(campaignData);
        } catch (error) {
          console.error('Error parsing campaign data from query params:', error);
        }
      }
    });
  }

  populateFormForEditing(campaignData: any) {
    console.log('Populating form for editing:', campaignData);

    // Populate basic form fields
    this.marketingForm.patchValue({
      campaignManager: campaignData.campaignManager,
      employeeCode: campaignData.employeeCode,
      taskDescription: campaignData.taskDescription,
      taskDate: campaignData.taskDate ? new Date(campaignData.taskDate).toISOString().split('T')[0] : '',
      deadline: campaignData.deadline ? new Date(campaignData.deadline).toISOString().split('T')[0] : '',
      priority: campaignData.priority,
      isUrgent: campaignData.isUrgent || false,
      state: campaignData.stateId?.toString(),
      city: campaignData.cityId?.toString(),
      locality: campaignData.locality,
      pincode: campaignData.pincode,
      clientName: campaignData.clientName,
      projectCode: campaignData.projectCode,
      consultantName: campaignData.consultantName,
      campCode: campaignData.campaignCode,
      estimatedHours: campaignData.estimatedHours,
      additionalNotes: campaignData.additionalNotes,
      consultantFeedback: campaignData.consultantFeedback,
      expectedReach: campaignData.expectedReach,
      conversionGoal: campaignData.conversionGoal,
      kpis: campaignData.kpis,
      marketingMaterials: campaignData.marketingMaterials,
      approvalRequired: campaignData.approvalRequired || true,
      approvalContact: campaignData.approvalContact,
      budgetCode: campaignData.budgetCode,
      departmentCode: campaignData.departmentCode || 'MKT'
    });

    // Set selected task types
    if (campaignData.selectedTaskTypes && Array.isArray(campaignData.selectedTaskTypes)) {
      this.selectedTaskTypes = campaignData.selectedTaskTypes;
    }

    // Load dependent data if state and city are set
    if (campaignData.stateId) {
      this.selectedStateId = campaignData.stateId;
      this.loadCities(campaignData.stateId);
    }

    if (campaignData.cityId) {
      this.selectedCityId = campaignData.cityId;
      // Load localities for the city
      this.loadLocalitiesForCity(campaignData.cityId);
    }

    console.log('Form populated for editing');
  }


  initializeTaskTypes() {
    this.taskTypes = [
      { taskTypeId: 1, typeName: 'Digital Marketing', description: 'Digital marketing activities' },
      { taskTypeId: 2, typeName: 'Social Media', description: 'Social media campaigns' },
      { taskTypeId: 3, typeName: 'Content Creation', description: 'Content creation and management' },
      { taskTypeId: 4, typeName: 'Email Marketing', description: 'Email marketing campaigns' },
      { taskTypeId: 5, typeName: 'Event Marketing', description: 'Event planning and marketing' },
      { taskTypeId: 6, typeName: 'Print Media', description: 'Print media campaigns' },
      { taskTypeId: 7, typeName: 'Radio/TV', description: 'Radio and TV advertisements' },
      { taskTypeId: 8, typeName: 'Outdoor Advertising', description: 'Billboards and outdoor ads' }
    ];
    console.log('Initialized with fallback task types:', this.taskTypes);
  }

  loadTaskTypes() {
    console.log('Loading task types from local data...');
    // Use fallback data only - NO API CALLS
    console.log('Using fallback task types:', this.taskTypes);
  }

  loadStates() {
    console.log('Loading states from database...');

    fetch(`${environment.apiUrl}/location/states`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.states = data.data;
          console.log('States loaded from database:', this.states.length);
        } else {
          console.error('Error loading states:', data.message);
          this.loadFallbackStates();
        }
      })
      .catch(error => {
        console.error('Error loading states from database:', error);
        this.loadFallbackStates();
      });
  }

  loadFallbackStates() {
    console.log('Loading fallback states...');
    this.states = [
      { stateId: 1, stateName: 'Andhra Pradesh', stateCode: 'AP' },
      { stateId: 2, stateName: 'Arunachal Pradesh', stateCode: 'AR' },
      { stateId: 3, stateName: 'Assam', stateCode: 'AS' },
      { stateId: 4, stateName: 'Bihar', stateCode: 'BR' },
      { stateId: 5, stateName: 'Chhattisgarh', stateCode: 'CG' },
      { stateId: 6, stateName: 'Goa', stateCode: 'GA' },
      { stateId: 7, stateName: 'Gujarat', stateCode: 'GJ' },
      { stateId: 8, stateName: 'Haryana', stateCode: 'HR' },
      { stateId: 9, stateName: 'Himachal Pradesh', stateCode: 'HP' },
      { stateId: 10, stateName: 'Jharkhand', stateCode: 'JH' },
      { stateId: 11, stateName: 'Karnataka', stateCode: 'KA' },
      { stateId: 12, stateName: 'Kerala', stateCode: 'KL' },
      { stateId: 13, stateName: 'Madhya Pradesh', stateCode: 'MP' },
      { stateId: 14, stateName: 'Maharashtra', stateCode: 'MH' },
      { stateId: 15, stateName: 'Manipur', stateCode: 'MN' },
      { stateId: 16, stateName: 'Meghalaya', stateCode: 'ML' },
      { stateId: 17, stateName: 'Mizoram', stateCode: 'MZ' },
      { stateId: 18, stateName: 'Nagaland', stateCode: 'NL' },
      { stateId: 19, stateName: 'Odisha', stateCode: 'OR' },
      { stateId: 20, stateName: 'Punjab', stateCode: 'PB' },
      { stateId: 21, stateName: 'Rajasthan', stateCode: 'RJ' },
      { stateId: 22, stateName: 'Sikkim', stateCode: 'SK' },
      { stateId: 23, stateName: 'Tamil Nadu', stateCode: 'TN' },
      { stateId: 24, stateName: 'Telangana', stateCode: 'TG' },
      { stateId: 25, stateName: 'Tripura', stateCode: 'TR' },
      { stateId: 26, stateName: 'Uttar Pradesh', stateCode: 'UP' },
      { stateId: 27, stateName: 'Uttarakhand', stateCode: 'UK' },
      { stateId: 28, stateName: 'West Bengal', stateCode: 'WB' },
      { stateId: 29, stateName: 'Delhi', stateCode: 'DL' },
      { stateId: 30, stateName: 'Jammu and Kashmir', stateCode: 'JK' },
      { stateId: 31, stateName: 'Ladakh', stateCode: 'LA' },
      { stateId: 32, stateName: 'Chandigarh', stateCode: 'CH' },
      { stateId: 33, stateName: 'Dadra and Nagar Haveli and Daman and Diu', stateCode: 'DN' },
      { stateId: 34, stateName: 'Lakshadweep', stateCode: 'LD' },
      { stateId: 35, stateName: 'Puducherry', stateCode: 'PY' },
      { stateId: 36, stateName: 'Andaman and Nicobar Islands', stateCode: 'AN' }
    ];
    console.log('Fallback states loaded:', this.states.length);
  }

  loadCities(stateId: number) {
    console.log('Loading cities from database for stateId:', stateId);

    fetch(`${environment.apiUrl}/location/cities?stateId=${stateId}`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.cities = data.data;
          console.log('Cities loaded from database:', this.cities.length);

          // Enable city field when cities are loaded
          if (this.cities.length > 0) {
            this.marketingForm.get('city')?.enable();
          }
        } else {
          console.error('Error loading cities:', data.message);
          this.loadFallbackCities(stateId);
        }
      })
      .catch(error => {
        console.error('Error loading cities from database:', error);
        this.loadFallbackCities(stateId);
      });
  }

  loadFallbackCities(stateId: number) {
    console.log('Loading fallback cities for stateId:', stateId);

    if (stateId === 29) { // Delhi
      this.cities = [
        { cityId: 1, cityName: 'Delhi', stateId: 29 }
      ];
    } else if (stateId === 14) { // Maharashtra
      this.cities = [
        { cityId: 2, cityName: 'Mumbai', stateId: 14 },
        { cityId: 3, cityName: 'Pune', stateId: 14 },
        { cityId: 4, cityName: 'Nagpur', stateId: 14 },
        { cityId: 5, cityName: 'Thane', stateId: 14 },
        { cityId: 6, cityName: 'Nashik', stateId: 14 }
      ];
    } else if (stateId === 11) { // Karnataka
      this.cities = [
        { cityId: 7, cityName: 'Bangalore', stateId: 11 },
        { cityId: 8, cityName: 'Mysore', stateId: 11 },
        { cityId: 9, cityName: 'Hubli', stateId: 11 },
        { cityId: 10, cityName: 'Mangalore', stateId: 11 }
      ];
    } else if (stateId === 23) { // Tamil Nadu
      this.cities = [
        { cityId: 11, cityName: 'Chennai', stateId: 23 },
        { cityId: 12, cityName: 'Coimbatore', stateId: 23 },
        { cityId: 13, cityName: 'Madurai', stateId: 23 },
        { cityId: 14, cityName: 'Tiruchirappalli', stateId: 23 }
      ];
    } else if (stateId === 7) { // Gujarat
      this.cities = [
        { cityId: 15, cityName: 'Ahmedabad', stateId: 7 },
        { cityId: 16, cityName: 'Surat', stateId: 7 },
        { cityId: 17, cityName: 'Vadodara', stateId: 7 },
        { cityId: 18, cityName: 'Rajkot', stateId: 7 }
      ];
    } else if (stateId === 1) { // Andhra Pradesh
      this.cities = [
        { cityId: 19, cityName: 'Hyderabad', stateId: 1 },
        { cityId: 20, cityName: 'Visakhapatnam', stateId: 1 },
        { cityId: 21, cityName: 'Vijayawada', stateId: 1 },
        { cityId: 22, cityName: 'Tirupati', stateId: 1 }
      ];
    } else {
      // Default cities for any other state
      this.cities = [
        { cityId: 1, cityName: 'Main City', stateId: stateId }
      ];
    }

    console.log('Fallback cities loaded:', this.cities.length);

    // Enable city field when cities are loaded
    if (this.cities.length > 0) {
      this.marketingForm.get('city')?.enable();
    }
  }


  onTaskTypeChange(event: any, taskTypeId: number) {
    console.log('=== TASK TYPE CHANGE ===');
    console.log('TaskTypeId:', taskTypeId);
    console.log('Checked:', event.target.checked);
    console.log('Current selectedTaskTypes:', this.selectedTaskTypes);

    if (event.target.checked) {
      if (!this.selectedTaskTypes.includes(taskTypeId)) {
        this.selectedTaskTypes.push(taskTypeId);
        console.log('Added task type:', taskTypeId);
      }
    } else {
      this.selectedTaskTypes = this.selectedTaskTypes.filter(id => id !== taskTypeId);
      console.log('Removed task type:', taskTypeId);
    }

    console.log('Updated selectedTaskTypes:', this.selectedTaskTypes);
    console.log('=== END TASK TYPE CHANGE ===');
  }


  // Locality search - Filter from loaded city localities only
  onLocalitySearch(event: any) {
    const searchTerm = event.target.value.toLowerCase();
    console.log('🔍 Searching localities with term:', searchTerm);
    console.log('📊 Available localities for current city:', this.localities.length);

    // Filter from the localities already loaded for selected city
    if (searchTerm.length > 0) {
      this.filteredLocalities = this.localities.filter(locality =>
        locality.localityName.toLowerCase().includes(searchTerm)
      );
      console.log('✅ Filtered to', this.filteredLocalities.length, 'localities');
    } else {
      // Show all localities for the selected city
      this.filteredLocalities = [...this.localities];
      console.log('✅ Showing all', this.filteredLocalities.length, 'localities for selected city');
    }

    this.showLocalityDropdown = true;
    this.highlightedIndex = -1;
  }

  onLocalityFocus() {
    console.log('🔍 Locality input focused');
    console.log('📊 Available localities for selected city:', this.localities.length);
    console.log('🏙️ Selected city ID:', this.selectedCityId);

    // Show dropdown with localities already loaded for the selected city
    if (this.localities.length > 0) {
      this.filteredLocalities = [...this.localities];
      this.showLocalityDropdown = true;
      console.log('✅ Showing', this.filteredLocalities.length, 'localities from selected city');
    } else {
      console.log('⚠️ No localities loaded. Please select a city first.');
      this.showLocalityDropdown = false;
    }
  }

  onLocalityBlur() {
    // Delay hiding to allow click events to register - increased to 500ms for better UX
    setTimeout(() => {
      this.showLocalityDropdown = false;
      this.highlightedIndex = -1;
    }, 500);
  }

  selectLocality(locality: any) {
    console.log('=== LOCALITY SELECTED ===');
    console.log('Full locality object:', locality);
    console.log('Locality ID:', locality.id);
    console.log('Locality Name:', locality.name || locality.localityName);

    this.selectedLocalityName = locality.localityName || locality.name;
    this.selectedLocalityId = locality.id || locality.localityId || null;  // ⭐ STORE LOCALITY ID
    console.log('✅ Stored selectedLocalityId:', this.selectedLocalityId);

    this.marketingForm.patchValue({ locality: this.selectedLocalityName });
    this.showLocalityDropdown = false;
    this.highlightedIndex = -1;

    // ⭐⭐⭐ DIRECT PINCODE AUTO-FETCH - SIMPLIFIED ⭐⭐⭐
    console.log('� ATTEMPTING PINCODE AUTO-FETCH...');

    // ATTEMPT 1: Use locality.id directly from parameter
    let localityId = locality.id;

    // ATTEMPT 2: If not found, search in localityObjects
    if (!localityId) {
      console.log('⚠️ No ID in locality parameter, searching localityObjects...');
      const localityObj = (this as any).localityObjects?.find((l: any) =>
        (l.name === this.selectedLocalityName) || (l.localityName === this.selectedLocalityName)
      );
      localityId = localityObj?.id;
      console.log('Found in localityObjects:', localityObj);
    }

    console.log('Final localityId to use:', localityId);

    if (localityId) {
      console.log('✅ Calling API with localityId:', localityId);

      this.locationHierarchyService.getPincodesByLocality(localityId).subscribe({
        next: (pincodes: any) => {
          console.log('✅✅ API RESPONSE RECEIVED!');
          console.log('Raw pincodes:', pincodes);
          console.log('Total count:', pincodes?.length);

          if (!pincodes || pincodes.length === 0) {
            console.error('❌ No pincodes returned from API!');
            this.filteredPincodes = [];
            return;
          }

          // ⭐ REMOVE DUPLICATES
          const uniquePincodes = Array.from(
            new Map(pincodes.map((p: any) => [p.pincode || p.Pincode, p])).values()
          );

          console.log('Unique pincodes:', uniquePincodes.length);
          this.filteredPincodes = uniquePincodes;

          // ⭐⭐⭐ AUTO-FILL IF SINGLE PINCODE ⭐⭐⭐
          if (uniquePincodes.length === 1) {
            const pincode = (uniquePincodes[0] as any).pincode || (uniquePincodes[0] as any).Pincode;
            console.log('🎯🎯 AUTO-FILLING PINCODE:', pincode);
            this.marketingForm.patchValue({ pincode: pincode });
            this.cdr.detectChanges();
            console.log('✅✅✅ PINCODE AUTO-FILLED SUCCESSFULLY!');
          } else {
            console.log('📋 Multiple pincodes, showing dropdown...');
            this.showPincodeDropdown = true;
            this.cdr.detectChanges();
          }
        },
        error: (err: any) => {
          console.error('❌❌ API ERROR:', err);
          console.error('Error message:', err.message);
          console.error('Error status:', err.status);

          // Try fallback
          console.log('Attempting fallback method...');
          if (this.selectedLocalityName) {
            this.loadPincodesForLocalityFromDB(this.selectedLocalityName);
          }
        }
      });
    } else {
      console.error('❌❌ NO LOCALITY ID FOUND! Cannot fetch pincodes.');
      console.error('Locality parameter:', locality);
      console.error('localityObjects:', (this as any).localityObjects);

      // Last resort fallback
      if (this.selectedLocalityName) {
        console.log('Trying database fallback...');
        this.loadPincodesForLocalityFromDB(this.selectedLocalityName);
      }
    }

    console.log('=== END LOCALITY SELECTION ===');
  }

  // Pincode search methods - USING DATABASE API
  onPincodeSearch(event: any) {
    const searchTerm = event.target.value.toLowerCase();
    console.log('Searching pincodes with term:', searchTerm);

    // Call database API to search pincodes
    if (searchTerm.length > 0) {
      this.searchPincodesFromDatabase(searchTerm);
    } else {
      this.loadAllPincodesFromDatabase();
    }

    this.showPincodeDropdown = true;
    this.highlightedPincodeIndex = -1;
  }

  onPincodeFocus() {
    console.log('Pincode input focused');
    console.log('Available pincodes:', this.allPincodeData);
    console.log('Current showPincodeDropdown:', this.showPincodeDropdown);

    // Always show dropdown immediately
    this.showPincodeDropdown = true;

    // Load pincodes from database
    this.loadAllPincodesFromDatabase();

    console.log('After setting showPincodeDropdown to true:', this.showPincodeDropdown);
    console.log('Filtered pincodes:', this.filteredPincodes);
  }

  onPincodeClick() {
    console.log('=== PINCODE CLICKED ===');
    console.log('Current showPincodeDropdown before:', this.showPincodeDropdown);
    console.log('Current filteredPincodes length:', this.filteredPincodes.length);
    console.log('Current allPincodeData length:', this.allPincodeData.length);

    // Force show dropdown immediately
    this.showPincodeDropdown = true;
    this.filteredPincodes = this.allPincodeData;

    console.log('After immediate set - showPincodeDropdown:', this.showPincodeDropdown);
    console.log('After immediate set - filteredPincodes:', this.filteredPincodes.length);

    // Also call focus method
    this.onPincodeFocus();

    console.log('=== END PINCODE CLICK ===');
  }

  onPincodeBlur() {
    // Delay hiding to allow click events to register
    setTimeout(() => {
      // Only hide if not clicking on dropdown options
      if (!this.isClickingOnDropdown) {
        this.showPincodeDropdown = false;
        this.highlightedPincodeIndex = -1;
      }
      this.isClickingOnDropdown = false;
    }, 300);
  }

  selectPincode(pincode: any) {
    console.log('=== PINCODE SELECTED ===');
    console.log('Pincode selected:', pincode);

    this.isClickingOnDropdown = true;
    this.marketingForm.patchValue({ pincode: pincode.pincode });
    this.showPincodeDropdown = false;
    this.highlightedPincodeIndex = -1;

    console.log('Form updated with pincode:', pincode.pincode);
    console.log('Dropdown hidden');
    console.log('=== END PINCODE SELECTION ===');
  }



  onPincodeMouseDown() {
    console.log('PINCODE MOUSEDOWN');
  }

  onPincodeMouseUp() {
    console.log('PINCODE MOUSEUP');
  }

  onLocalityMouseDown(locality: any) {
    console.log('Locality mousedown:', locality.localityName);
  }

  onLocalityMouseUp(locality: any) {
    console.log('Locality mouseup:', locality.localityName);
  }

  loadLocalitiesForCity(cityId: number) {
    console.log('loadLocalitiesForCity called with cityId:', cityId);
    this.loadAllLocalitiesForCity(cityId);
  }

  loadAllLocalitiesForCity(cityId: number) {
    console.log('Loading all localities for city:', cityId);
    // For now, use fallback data based on city
    this.loadFallbackLocalitiesForCity(cityId);
  }

  loadFallbackLocalitiesForCity(cityId: number) {
    console.log('loadFallbackLocalitiesForCity called with cityId:', cityId);

    // Use the actual data from your database table
    const allLocalities = [
      { localityName: 'Connaught Place' },
      { localityName: 'Darya Ganj' },
      { localityName: 'Kashmere Gate' },
      { localityName: 'Red Fort' },
      { localityName: 'India Gate' },
      { localityName: 'Central Secretariat' },
      { localityName: 'President Estate' },
      { localityName: 'Raj Ghat' },
      { localityName: 'Parliament House' },
      { localityName: 'Lajpat Nagar' },
      { localityName: 'Defence Colony' },
      { localityName: 'Greater Kailash' },
      { localityName: 'Green Park' },
      { localityName: 'Hauz Khas' },
      { localityName: 'Malviya Nagar' },
      { localityName: 'Saket' },
      { localityName: 'Nehru Place' },
      { localityName: 'Vasant Kunj' },
      { localityName: 'Vasant Vihar' },
      { localityName: 'Civil Lines' },
      { localityName: 'Kamla Nagar' },
      { localityName: 'Kingsway Camp' },
      { localityName: 'Gtb Nagar' },
      { localityName: 'Model Town' },
      { localityName: 'Karol Bagh' },
      { localityName: 'Rajouri Garden' },
      { localityName: 'Naraina' },
      { localityName: 'Patel Nagar' },
      { localityName: 'Janakpuri' },
      { localityName: 'Tilak Nagar' },
      { localityName: 'Vikaspuri' },
      { localityName: 'Laxmi Nagar' },
      { localityName: 'Preet Vihar' },
      { localityName: 'I P Extension' },
      { localityName: 'Mayur Vihar' },
      { localityName: 'Patparganj' },
      // Mumbai localities
      { localityName: 'Fort' },
      { localityName: 'Kalbadevi' },
      { localityName: 'Masjid Bunder' },
      { localityName: 'Girgaon' },
      { localityName: 'Colaba' },
      { localityName: 'Malabar Hill' },
      { localityName: 'Grant Road' },
      { localityName: 'Mumbai Central' },
      { localityName: 'Mazgaon' },
      { localityName: 'Tardeo' },
      // Bangalore localities
      { localityName: 'Bangalore City' },
      { localityName: 'Bangalore Cantonment' },
      { localityName: 'Malleshwaram' },
      { localityName: 'Rajajinagar' },
      { localityName: 'Seshadripuram' },
      { localityName: 'Chamrajpet' },
      { localityName: 'Chamarajpet' },
      { localityName: 'Chickpet' },
      { localityName: 'Balepet' },
      { localityName: 'Vyalikaval' },
      // Chennai localities
      { localityName: 'Parrys Corner' },
      { localityName: 'Sowcarpet' },
      { localityName: 'Chintadripet' },
      { localityName: 'Mylapore' },
      { localityName: 'Triplicane' },
      { localityName: 'Chepauk' },
      { localityName: 'Vepery' },
      { localityName: 'Egmore' },
      { localityName: 'Purasawalkam' },
      { localityName: 'Kilpauk' },
      // Ahmedabad localities
      { localityName: 'Lal Darwaja' },
      { localityName: 'Kalupur' },
      { localityName: 'Maninagar' },
      { localityName: 'Navrangpura' },
      { localityName: 'Kankaria' },
      { localityName: 'Narol' },
      { localityName: 'Sabarmati' },
      { localityName: 'Vastrapur' },
      { localityName: 'Ghatlodia' },
      { localityName: 'Ambawadi' }
    ];

    this.localities = allLocalities;
    this.filteredLocalities = allLocalities;
    console.log('All localities loaded for city:', cityId, this.localities.length, 'localities');
  }



  loadPincodesForLocalityFromDB(localityName: string) {
    console.log('loadPincodesForLocalityFromDB called with localityName:', localityName);

    // Use local data only - NO API CALLS
    this.loadPincodesForLocality(localityName);
  }

  loadPincodesForLocality(localityName: string) {
    console.log('loadPincodesForLocality called with localityName:', localityName);

    // Filter pincodes from the loaded database data
    if (this.allPincodeData && this.allPincodeData.length > 0) {
      this.pincodes = this.allPincodeData.filter(p =>
        p.localityName.toLowerCase().includes(localityName.toLowerCase())
      );
      this.filteredPincodes = this.pincodes;

      // Auto-select the first pincode if only one exists
      if (this.pincodes.length === 1) {
        this.marketingForm.patchValue({ pincode: this.pincodes[0].pincode });
        console.log('Auto-selected pincode from local data:', this.pincodes[0].pincode);
      }
    } else {
      // Fallback to hardcoded data if database data not loaded
      this.loadFallbackPincodes(localityName);
      this.filteredPincodes = this.pincodes;
    }
  }

  // Load all localities - USING LOCAL DATA ONLY
  loadAllLocalities() {
    console.log('Loading all localities from local data...');
    // Use comprehensive fallback data only - NO API CALLS
    this.loadComprehensiveLocalities();
  }

  // Load comprehensive localities from your provided data
  loadComprehensiveLocalities() {
    console.log('Loading comprehensive localities from provided data...');

    // Your comprehensive pincode data with localities
    const comprehensiveData = [
      // Delhi localities
      { pincodeId: 161, pincode: '110001', areaId: 1, localityName: 'Connaught Place', isActive: 1 },
      { pincodeId: 162, pincode: '110002', areaId: 1, localityName: 'Darya Ganj', isActive: 1 },
      { pincodeId: 163, pincode: '110003', areaId: 1, localityName: 'Kashmere Gate', isActive: 1 },
      { pincodeId: 164, pincode: '110006', areaId: 1, localityName: 'Red Fort', isActive: 1 },
      { pincodeId: 165, pincode: '110055', areaId: 1, localityName: 'India Gate', isActive: 1 },
      { pincodeId: 166, pincode: '110011', areaId: 10, localityName: 'Central Secretariat', isActive: 1 },
      { pincodeId: 167, pincode: '110021', areaId: 10, localityName: 'President Estate', isActive: 1 },
      { pincodeId: 168, pincode: '110023', areaId: 10, localityName: 'Raj Ghat', isActive: 1 },
      { pincodeId: 169, pincode: '110012', areaId: 10, localityName: 'Parliament House', isActive: 1 },
      { pincodeId: 170, pincode: '110016', areaId: 3, localityName: 'Lajpat Nagar', isActive: 1 },
      { pincodeId: 171, pincode: '110017', areaId: 3, localityName: 'Defence Colony', isActive: 1 },
      { pincodeId: 172, pincode: '110019', areaId: 3, localityName: 'Greater Kailash', isActive: 1 },
      { pincodeId: 173, pincode: '110024', areaId: 3, localityName: 'Green Park', isActive: 1 },
      { pincodeId: 174, pincode: '110025', areaId: 3, localityName: 'Hauz Khas', isActive: 1 },
      { pincodeId: 175, pincode: '110029', areaId: 3, localityName: 'Malviya Nagar', isActive: 1 },
      { pincodeId: 176, pincode: '110048', areaId: 3, localityName: 'Saket', isActive: 1 },
      { pincodeId: 177, pincode: '110049', areaId: 3, localityName: 'Nehru Place', isActive: 1 },
      { pincodeId: 178, pincode: '110062', areaId: 3, localityName: 'Vasant Kunj', isActive: 1 },
      { pincodeId: 179, pincode: '110070', areaId: 3, localityName: 'Vasant Vihar', isActive: 1 },
      { pincodeId: 180, pincode: '110007', areaId: 2, localityName: 'Civil Lines', isActive: 1 },
      { pincodeId: 181, pincode: '110009', areaId: 2, localityName: 'Kamla Nagar', isActive: 1 },
      { pincodeId: 182, pincode: '110033', areaId: 2, localityName: 'Kingsway Camp', isActive: 1 },
      { pincodeId: 183, pincode: '110035', areaId: 2, localityName: 'Gtb Nagar', isActive: 1 },
      { pincodeId: 184, pincode: '110054', areaId: 2, localityName: 'Model Town', isActive: 1 },
      { pincodeId: 185, pincode: '110015', areaId: 5, localityName: 'Karol Bagh', isActive: 1 },
      { pincodeId: 186, pincode: '110018', areaId: 5, localityName: 'Rajouri Garden', isActive: 1 },
      { pincodeId: 187, pincode: '110026', areaId: 5, localityName: 'Naraina', isActive: 1 },
      { pincodeId: 188, pincode: '110027', areaId: 5, localityName: 'Patel Nagar', isActive: 1 },
      { pincodeId: 189, pincode: '110058', areaId: 5, localityName: 'Janakpuri', isActive: 1 },
      { pincodeId: 190, pincode: '110059', areaId: 5, localityName: 'Tilak Nagar', isActive: 1 },
      { pincodeId: 191, pincode: '110063', areaId: 5, localityName: 'Vikaspuri', isActive: 1 },
      { pincodeId: 192, pincode: '110031', areaId: 4, localityName: 'Laxmi Nagar', isActive: 1 },
      { pincodeId: 193, pincode: '110032', areaId: 4, localityName: 'Preet Vihar', isActive: 1 },
      { pincodeId: 194, pincode: '110051', areaId: 4, localityName: 'I P Extension', isActive: 1 },
      { pincodeId: 195, pincode: '110092', areaId: 4, localityName: 'Mayur Vihar', isActive: 1 },
      { pincodeId: 196, pincode: '110096', areaId: 4, localityName: 'Patparganj', isActive: 1 }
    ];

    // Convert to the format expected by the component
    this.localities = comprehensiveData.map(item => ({
      pincodeId: item.pincodeId,
      pincode: item.pincode,
      areaId: item.areaId,
      localityName: item.localityName,
      isActive: item.isActive
    }));

    this.filteredLocalities = [...this.localities];
    console.log('Comprehensive localities loaded:', this.localities.length, 'records');
    console.log('Filtered localities updated:', this.filteredLocalities.length, 'records');
  }

  // Load all pincode data - USING LOCAL DATA ONLY
  loadAllPincodeData() {
    console.log('Loading all pincode data from local data...');
    // Use comprehensive fallback data only - NO API CALLS
    this.loadComprehensivePincodes();
  }

  // Load comprehensive pincode data from your provided data
  loadComprehensivePincodes() {
    console.log('Loading comprehensive pincode data from provided data...');

    // Use the same comprehensive data for pincodes
    const comprehensiveData = [
      // Delhi pincodes
      { pincodeId: 161, pincode: '110001', areaId: 1, localityName: 'Connaught Place', isActive: 1 },
      { pincodeId: 162, pincode: '110002', areaId: 1, localityName: 'Darya Ganj', isActive: 1 },
      { pincodeId: 163, pincode: '110003', areaId: 1, localityName: 'Kashmere Gate', isActive: 1 },
      { pincodeId: 164, pincode: '110006', areaId: 1, localityName: 'Red Fort', isActive: 1 },
      { pincodeId: 165, pincode: '110055', areaId: 1, localityName: 'India Gate', isActive: 1 },
      { pincodeId: 166, pincode: '110011', areaId: 10, localityName: 'Central Secretariat', isActive: 1 },
      { pincodeId: 167, pincode: '110021', areaId: 10, localityName: 'President Estate', isActive: 1 },
      { pincodeId: 168, pincode: '110023', areaId: 10, localityName: 'Raj Ghat', isActive: 1 },
      { pincodeId: 169, pincode: '110012', areaId: 10, localityName: 'Parliament House', isActive: 1 },
      { pincodeId: 170, pincode: '110016', areaId: 3, localityName: 'Lajpat Nagar', isActive: 1 },
      { pincodeId: 171, pincode: '110017', areaId: 3, localityName: 'Defence Colony', isActive: 1 },
      { pincodeId: 172, pincode: '110019', areaId: 3, localityName: 'Greater Kailash', isActive: 1 },
      { pincodeId: 173, pincode: '110024', areaId: 3, localityName: 'Green Park', isActive: 1 },
      { pincodeId: 174, pincode: '110025', areaId: 3, localityName: 'Hauz Khas', isActive: 1 },
      { pincodeId: 175, pincode: '110029', areaId: 3, localityName: 'Malviya Nagar', isActive: 1 },
      { pincodeId: 176, pincode: '110048', areaId: 3, localityName: 'Saket', isActive: 1 },
      { pincodeId: 177, pincode: '110049', areaId: 3, localityName: 'Nehru Place', isActive: 1 },
      { pincodeId: 178, pincode: '110062', areaId: 3, localityName: 'Vasant Kunj', isActive: 1 },
      { pincodeId: 179, pincode: '110070', areaId: 3, localityName: 'Vasant Vihar', isActive: 1 },
      { pincodeId: 180, pincode: '110007', areaId: 2, localityName: 'Civil Lines', isActive: 1 },
      { pincodeId: 181, pincode: '110009', areaId: 2, localityName: 'Kamla Nagar', isActive: 1 },
      { pincodeId: 182, pincode: '110033', areaId: 2, localityName: 'Kingsway Camp', isActive: 1 },
      { pincodeId: 183, pincode: '110035', areaId: 2, localityName: 'Gtb Nagar', isActive: 1 },
      { pincodeId: 184, pincode: '110054', areaId: 2, localityName: 'Model Town', isActive: 1 },
      { pincodeId: 185, pincode: '110015', areaId: 5, localityName: 'Karol Bagh', isActive: 1 },
      { pincodeId: 186, pincode: '110018', areaId: 5, localityName: 'Rajouri Garden', isActive: 1 },
      { pincodeId: 187, pincode: '110026', areaId: 5, localityName: 'Naraina', isActive: 1 },
      { pincodeId: 188, pincode: '110027', areaId: 5, localityName: 'Patel Nagar', isActive: 1 },
      { pincodeId: 189, pincode: '110058', areaId: 5, localityName: 'Janakpuri', isActive: 1 },
      { pincodeId: 190, pincode: '110059', areaId: 5, localityName: 'Tilak Nagar', isActive: 1 },
      { pincodeId: 191, pincode: '110063', areaId: 5, localityName: 'Vikaspuri', isActive: 1 },
      { pincodeId: 192, pincode: '110031', areaId: 4, localityName: 'Laxmi Nagar', isActive: 1 },
      { pincodeId: 193, pincode: '110032', areaId: 4, localityName: 'Preet Vihar', isActive: 1 },
      { pincodeId: 194, pincode: '110051', areaId: 4, localityName: 'I P Extension', isActive: 1 },
      { pincodeId: 195, pincode: '110092', areaId: 4, localityName: 'Mayur Vihar', isActive: 1 },
      { pincodeId: 196, pincode: '110096', areaId: 4, localityName: 'Patparganj', isActive: 1 }
    ];

    // Convert to the format expected by the component
    this.allPincodeData = comprehensiveData.map(item => ({
      pincodeId: item.pincodeId,
      pincode: item.pincode,
      areaId: item.areaId,
      localityName: item.localityName,
      isActive: item.isActive
    }));

    this.pincodes = [...this.allPincodeData];
    this.filteredPincodes = [...this.allPincodeData];
    console.log('Comprehensive pincode data loaded:', this.pincodes.length, 'records');
    console.log('Filtered pincodes updated:', this.filteredPincodes.length, 'records');
  }

  loadFallbackPincodes(localityName: string) {
    console.log('loadFallbackPincodes called with localityName:', localityName);

    // Use the actual database data you provided - Delhi pincodes
    const allPincodeData = [
      { pincode: '110001', localityName: 'Connaught Place' },
      { pincode: '110002', localityName: 'Darya Ganj' },
      { pincode: '110003', localityName: 'Kashmere Gate' },
      { pincode: '110006', localityName: 'Red Fort' },
      { pincode: '110055', localityName: 'India Gate' },
      { pincode: '110011', localityName: 'Central Secretariat' },
      { pincode: '110021', localityName: 'President Estate' },
      { pincode: '110023', localityName: 'Raj Ghat' },
      { pincode: '110012', localityName: 'Parliament House' },
      { pincode: '110016', localityName: 'Lajpat Nagar' },
      { pincode: '110017', localityName: 'Defence Colony' },
      { pincode: '110019', localityName: 'Greater Kailash' },
      { pincode: '110024', localityName: 'Green Park' },
      { pincode: '110025', localityName: 'Hauz Khas' },
      { pincode: '110029', localityName: 'Malviya Nagar' },
      { pincode: '110048', localityName: 'Saket' },
      { pincode: '110049', localityName: 'Nehru Place' },
      { pincode: '110062', localityName: 'Vasant Kunj' },
      { pincode: '110070', localityName: 'Vasant Vihar' },
      { pincode: '110007', localityName: 'Civil Lines' },
      { pincode: '110009', localityName: 'Kamla Nagar' },
      { pincode: '110033', localityName: 'Kingsway Camp' },
      { pincode: '110035', localityName: 'GTB Nagar' },
      { pincode: '110054', localityName: 'Model Town' },
      { pincode: '110015', localityName: 'Karol Bagh' },
      { pincode: '110018', localityName: 'Rajouri Garden' },
      { pincode: '110026', localityName: 'Naraina' },
      { pincode: '110027', localityName: 'Patel Nagar' },
      { pincode: '110058', localityName: 'Janakpuri' },
      { pincode: '110059', localityName: 'Tilak Nagar' },
      { pincode: '110063', localityName: 'Vikaspuri' },
      { pincode: '110031', localityName: 'Laxmi Nagar' },
      { pincode: '110032', localityName: 'Preet Vihar' },
      { pincode: '110051', localityName: 'I P Extension' },
      { pincode: '110092', localityName: 'Mayur Vihar' },
      { pincode: '110096', localityName: 'Patparganj' }
    ];

    // Filter pincodes based on locality name or show all if no specific locality
    if (localityName && localityName.trim() !== '') {
      this.pincodes = allPincodeData.filter(p =>
        p.localityName.toLowerCase().includes(localityName.toLowerCase())
      );
    } else {
      this.pincodes = allPincodeData;
    }

    console.log('Pincodes loaded for locality:', localityName, this.pincodes.length, 'pincodes');
  }


  onSubmit() {
    console.log('Form submission started');
    console.log('Form valid:', this.marketingForm.valid);
    console.log('Form value:', this.marketingForm.value);
    console.log('Selected task types:', this.selectedTaskTypes);

    // Check if at least one task type is selected
    if (this.selectedTaskTypes.length === 0) {
      this.notificationService.showNotification('Please select at least one campaign type.', 'error');
      return;
    }

    if (this.marketingForm.valid) {
      this.isLoading = true;
      this.showSuccess = false;

      const formData = this.marketingForm.value;
      console.log('Form data:', formData);

      // Prepare data for database saving
      const marketingData: Partial<MarketingCampaignData> = {
        campaignManager: formData.campaignManager,
        employeeCode: formData.employeeCode,
        taskDescription: formData.taskDescription,
        taskDate: formData.taskDate,
        deadline: formData.deadline,
        priority: formData.priority,
        isUrgent: formData.isUrgent || false,

        // Location data - handle both manual and hierarchical
        stateId: this.manualLocationEntry ? 0 : (parseInt(formData.state) || 0),
        cityId: this.manualLocationEntry ? 0 : (parseInt(formData.city) || 0),
        locality: this.manualLocationEntry ? (formData.customLocation || '') : (formData.locality || ''),
        pincode: this.manualLocationEntry ? '' : (formData.pincode || ''),
        localityId: this.selectedLocalityId || undefined,  // ⭐ FIX: Convert null to undefined
        pincodeId: this.selectedPincodeId || undefined,    // ⭐ FIX: Convert null to undefined

        // Marketing fields
        clientName: formData.clientName,
        projectCode: formData.projectCode,
        consultantName: formData.consultantName,
        // ⭐ campaignCode not sent - Backend will auto-generate this
        estimatedHours: formData.estimatedHours ? parseFloat(formData.estimatedHours) : undefined,
        expectedReach: formData.expectedReach ? parseInt(formData.expectedReach) : undefined,
        conversionGoal: formData.conversionGoal,
        kpis: formData.kpis,
        marketingMaterials: formData.marketingMaterials,
        approvalRequired: formData.approvalRequired || false,
        approvalContact: formData.approvalContact,
        budgetCode: formData.budgetCode,
        additionalNotes: formData.additionalNotes,
        consultantFeedback: formData.consultantFeedback,

        // Selected task types
        selectedTaskTypes: this.selectedTaskTypes,
        status: 'Active'
      };

      // 🔍 DETAILED LOGGING FOR DEBUGGING
      console.log('📊 ===== PAYLOAD TO BE SENT TO BACKEND =====');
      console.log('✅ Campaign Manager:', marketingData.campaignManager);
      console.log('✅ Task Description:', marketingData.taskDescription);
      console.log('✅ Task Date:', marketingData.taskDate);
      console.log('✅ Deadline:', marketingData.deadline);
      console.log('✅ Priority:', marketingData.priority);
      console.log('✅ Selected Task Types:', marketingData.selectedTaskTypes);
      console.log('✅ State ID:', marketingData.stateId);
      console.log('✅ City ID:', marketingData.cityId);
      console.log('✅ Locality:', marketingData.locality);
      console.log('✅ Pincode:', marketingData.pincode);
      console.log('📊 FULL JSON PAYLOAD:');
      console.log(JSON.stringify(marketingData, null, 2));
      console.log('📊 ==========================================');

      // Save to database via API
      this.saveCampaignToDatabase(marketingData);
    } else {
      console.log('Form is not ready for submission');
      this.markFormGroupTouched();

      this.notificationService.showNotification('Please fill in all required fields correctly.', 'error');
    }
  }

  // Save campaign to database via API
  saveCampaignToDatabase(campaignData: Partial<MarketingCampaignData>) {
    console.log('Saving campaign to database:', campaignData);

    this.marketingFormService.saveMarketingCampaign(campaignData).subscribe({
      next: (response) => {
        this.isLoading = false;

        if (response.success) {
          this.showSuccess = true;
          this.successMessage = 'Marketing campaign saved successfully!';
          this.errorMessage = '';

          // Print the form after successful submission
          this.printForm();

          console.log('Marketing campaign saved successfully:', response);
          this.notificationService.showNotification('Marketing campaign saved successfully! Form printed.');

          // Clear the form
          this.resetForm();

          // Navigate to dashboard after 3 seconds
          setTimeout(() => {
            this.showSuccess = false;
            this.router.navigate(['/admin/dashboard']);
          }, 3000);
        } else {
          console.error('Error saving campaign:', response.message);
          this.errorMessage = response.message || 'Failed to save campaign';
          this.successMessage = '';
          this.notificationService.showNotification('Error saving campaign: ' + response.message, 'error');
        }
      },
      error: (error) => {
        this.isLoading = false;
        console.error('Error saving campaign:', error);
        this.errorMessage = error.message || 'Unable to save form, please try again';
        this.successMessage = '';
        this.notificationService.showNotification('Error saving campaign: ' + error.message, 'error');
      }
    });
  }

  saveCampaignToStorage(campaignData: any) {
    try {
      // Get existing campaigns
      const existingCampaigns = JSON.parse(localStorage.getItem('marketingCampaigns') || '[]');

      // Add new campaign
      existingCampaigns.push(campaignData);

      // Save back to localStorage
      localStorage.setItem('marketingCampaigns', JSON.stringify(existingCampaigns));

      console.log('Campaign saved to storage. Total campaigns:', existingCampaigns.length);
    } catch (error) {
      console.error('Error saving campaign to storage:', error);
    }
  }

  // Get all saved campaigns
  getAllSavedCampaigns() {
    try {
      return JSON.parse(localStorage.getItem('marketingCampaigns') || '[]');
    } catch (error) {
      console.error('Error loading campaigns from storage:', error);
      return [];
    }
  }

  printForm() {
    console.log('=== PRINTING FORM ===');

    // Create a new window for printing
    const printWindow = window.open('', '_blank');
    if (!printWindow) {
      alert('Please allow popups to print the form');
      return;
    }

    const formData = this.marketingForm.value;
    const selectedTaskTypes = this.selectedTaskTypes.map(id =>
      this.taskTypes.find(t => t.taskTypeId === id)?.typeName || 'Unknown'
    ).join(', ');

    const stateName = this.states.find(s => s.stateId == formData.state)?.stateName || formData.state;
    const cityName = this.cities.find(c => c.cityId == formData.city)?.cityName || formData.city;

    const printContent = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Marketing Campaign Form - Print</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                background: #f5f5f5;
                padding: 0;
                line-height: 1.6; 
            }
            
            /* Professional Teal Header */
            .professional-header {
                background: linear-gradient(135deg, #0d9488 0%, #14b8a6 100%);
                padding: 30px 0;
                text-align: center;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                margin-bottom: 30px;
            }
            
            .header-content {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 20px;
                flex-wrap: wrap;
            }
            
            .logo-placeholder {
                width: 80px;
                height: 80px;
                background: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                color: #0d9488;
                font-size: 14px;
                text-align: center;
                padding: 10px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            }
            
            .header-title {
                color: white;
                text-align: center;
            }
            
            .header-title h1 {
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 8px;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
            }
            
            .header-subtitle {
                font-size: 16px;
                color: #e0f2f1;
                font-weight: 400;
            }
            
            /* Main Container */
            .container {
                max-width: 900px;
                margin: 0 auto;
                padding: 30px;
                background: white;
                border: 2px solid #0d9488;
                border-radius: 10px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            
            .generated-info {
                text-align: center;
                color: #666;
                font-size: 14px;
                margin-bottom: 30px;
                padding: 10px;
                background: #f0fdfa;
                border-left: 4px solid #0d9488;
                border-radius: 4px;
            }
            
            /* Section Styling */
            .section {
                margin-bottom: 30px;
                border: 2px solid #e5e7eb;
                padding: 20px;
                border-radius: 8px;
                background: #fafafa;
            }
            
            .section-title {
                font-weight: 700;
                font-size: 18px;
                color: #0d9488;
                margin-bottom: 18px;
                padding-bottom: 10px;
                border-bottom: 2px solid #0d9488;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            /* Field Styling */
            .field {
                margin-bottom: 12px;
                padding: 8px 0;
                display: flex;
                border-bottom: 1px solid #e5e7eb;
            }
            
            .field:last-child {
                border-bottom: none;
            }
            
            .field-label {
                font-weight: 600;
                color: #374151;
                min-width: 220px;
                padding-right: 15px;
            }
            
            .field-value {
                color: #1f2937;
                flex: 1;
            }
            
            .urgent {
                color: #dc2626;
                font-weight: bold;
                text-transform: uppercase;
            }
            
            /* Checkbox List */
            .checkbox-list {
                margin-left: 20px;
                list-style-type: none;
            }
            
            .checkbox-list li {
                margin-bottom: 8px;
                padding-left: 25px;
                position: relative;
            }
            
            .checkbox-list li:before {
                content: "✓";
                position: absolute;
                left: 0;
                color: #0d9488;
                font-weight: bold;
                font-size: 18px;
            }
            
            /* Print Buttons */
            .print-buttons {
                text-align: center;
                margin: 20px 0 30px;
                padding: 15px;
                background: #f0fdfa;
                border-radius: 8px;
            }
            
            .print-btn {
                padding: 12px 30px;
                margin: 5px;
                background: linear-gradient(135deg, #0d9488 0%, #14b8a6 100%);
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 16px;
                font-weight: 600;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                transition: all 0.3s ease;
            }
            
            .print-btn:hover {
                background: linear-gradient(135deg, #0f766e 0%, #0d9488 100%);
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            }
            
            /* Print Media Query */
            @media print {
                body {
                    background: white;
                    padding: 0;
                    margin: 0;
                }
                
                .print-buttons {
                    display: none !important;
                }
                
                .container {
                    border: none;
                    box-shadow: none;
                    max-width: 100%;
                    padding: 20px;
                }
                
                .professional-header {
                    margin-bottom: 20px;
                    -webkit-print-color-adjust: exact;
                    print-color-adjust: exact;
                }
                
                .section {
                    page-break-inside: avoid;
                    border: 1px solid #ccc;
                }
            }
        </style>
    </head>
    <body>
        
        <!-- Professional Compact Header -->
        <div style="background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 50%, #0284c7 100%); padding: 15px 20px; margin-bottom: 25px; border-radius: 6px; box-shadow: 0 3px 10px rgba(14, 165, 233, 0.2);">
            <div style="text-align: center;">
                <div style="font-size: 9px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 5px; color: #1f2937; font-weight: 600;">Official Document</div>
                <h1 style="font-size: 20px; color: #000000; margin: 0 0 6px 0; font-weight: 700; letter-spacing: -0.3px;">Marketing Campaign Form</h1>
                <h2 style="font-size: 13px; color: #1f2937; margin: 0 0 6px 0; font-weight: 500;">Sri Balaji Action Medical Institute & Action Cancer Hospital</h2>
                <div style="display: inline-block; background: #67e8f9; padding: 4px 12px; border-radius: 15px; margin-top: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.12);">
                    <span style="font-size: 11px; color: #0c4a6e; font-weight: 600;">📅 ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', dateStyle: 'long', timeStyle: 'short' })}</span>
                </div>
            </div>
        </div>
        
        <div class="container">

            <div class="section">
                <div class="section-title">📋 Campaign Information</div>
                <div class="field"><span class="field-label">Campaign Manager:</span> <span class="field-value">${formData.campaignManager || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Employee ID:</span> <span class="field-value">${formData.employeeCode || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Campaign Description:</span> <span class="field-value">${formData.taskDescription || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Start Date:</span> <span class="field-value">${formData.taskDate || 'N/A'}</span></div>
                <div class="field"><span class="field-label">End Date:</span> <span class="field-value">${formData.deadline || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Priority:</span> <span class="field-value">${formData.priority || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Urgent Campaign:</span> <span class="field-value ${formData.isUrgent ? 'urgent' : ''}">${formData.isUrgent ? 'YES' : 'NO'}</span></div>
            </div>

            <div class="section">
                <div class="section-title">🏢 Project & Client Information</div>
                <div class="field"><span class="field-label">Client/Department:</span> <span class="field-value">${formData.clientName || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Project Code:</span> <span class="field-value">${formData.projectCode || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Consultant Name:</span> <span class="field-value">${formData.consultantName || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Campaign Code:</span> <span class="field-value">${formData.campCode || 'N/A'}</span></div>
            </div>

            <div class="section">
                <div class="section-title">📍 Location Details</div>
                <div class="field"><span class="field-label">State:</span> <span class="field-value">${stateName || 'N/A'}</span></div>
                <div class="field"><span class="field-label">City:</span> <span class="field-value">${cityName || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Locality:</span> <span class="field-value">${formData.locality || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Pincode:</span> <span class="field-value">${formData.pincode || 'N/A'}</span></div>
            </div>

            <div class="section">
                <div class="section-title">✅ Campaign Types</div>
                <div class="field">
                    <span class="field-label">Selected Types:</span>
                    <ul class="checkbox-list">
                        ${selectedTaskTypes.split(', ').map(type => `<li>${type}</li>`).join('')}
                    </ul>
                </div>
            </div>

            <div class="section">
                <div class="section-title">📊 Campaign Details</div>
                <div class="field"><span class="field-label">Expected Reach:</span> <span class="field-value">${formData.expectedReach || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Conversion Goal:</span> <span class="field-value">${formData.conversionGoal || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Estimated Hours:</span> <span class="field-value">${formData.estimatedHours || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Budget Code:</span> <span class="field-value">${formData.budgetCode || 'N/A'}</span></div>
                <div class="field"><span class="field-label">KPIs:</span> <span class="field-value">${formData.kpis || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Marketing Materials:</span> <span class="field-value">${formData.marketingMaterials || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Approval Required:</span> <span class="field-value">${formData.approvalRequired ? 'YES' : 'NO'}</span></div>
                <div class="field"><span class="field-label">Approval Contact:</span> <span class="field-value">${formData.approvalContact || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Additional Notes:</span> <span class="field-value">${formData.additionalNotes || 'N/A'}</span></div>
                <div class="field"><span class="field-label">Consultant Feedback:</span> <span class="field-value">${formData.consultantFeedback || 'N/A'}</span></div>
            </div>

            <div class="section">
                <div class="section-title">✓ Form Status</div>
                <div class="field"><span class="field-label">Form Status:</span> <span class="field-value" style="color: #059669; font-weight: bold;">COMPLETED & SUBMITTED</span></div>
                <div class="field"><span class="field-label">Submission Date:</span> <span class="field-value">${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })}</span></div>
            </div>
        </div>
        
        <!-- Print Buttons at Bottom -->
        <div class="print-buttons">
            <button class="print-btn" style="background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);" onclick="window.print()">🖨️ PRINT NOW</button>
            <button class="print-btn" style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white;" onclick="window.close()"><span style="color: white; font-weight: bold;">✖</span> CLOSE</button>
        </div>
    </body>
    </html>
    `;

    printWindow.document.write(printContent);
    printWindow.document.close();

    console.log('=== PRINT PREVIEW OPENED ===');
  }


  resetForm() {
    this.marketingForm.reset({
      priority: 'Medium',
      isUrgent: false,
      approvalRequired: true,
      departmentCode: 'MKT'
    });
    this.selectedTaskTypes = [];
    this.cities = [];
    this.localities = [];
    this.pincodes = [];
    this.selectedStateId = null;
    this.selectedCityId = null;
    this.selectedLocalityName = null;
    this.selectedLocalityId = null;   // ⭐ RESET: Clear locality ID
    this.selectedPincodeId = null;    // ⭐ RESET: Clear pincode ID

    // Reset form state
    this.isLoading = false;
    this.showSuccess = false;

    // Re-enable locality field and reload data
    this.marketingForm.get('locality')?.enable();
    this.loadAllLocalities();
  }

  private markFormGroupTouched() {
    Object.keys(this.marketingForm.controls).forEach(key => {
      const control = this.marketingForm.get(key);
      control?.markAsTouched();
    });
  }

  // State change handler - Using LocationHierarchyService
  // OLD METHODS REMOVED - NOW USING ADMIN-TASK-MODAL VERSIONS AT END OF FILE


  // Checkbox change handler
  onCheckboxChange(event: any, controlName: string) {
    const isChecked = event.target.checked;
    console.log('Checkbox changed:', controlName, isChecked);
    this.marketingForm.patchValue({ [controlName]: isChecked });
  }

  // Manual entry toggle handler
  onManualEntryToggle(): void {
    console.log('🔄 Manual entry toggle:', this.useManualEntry);

    if (this.useManualEntry) {
      // Clear hierarchical location fields when switching to manual
      this.marketingForm.patchValue({
        state: '',
        city: '',
        locality: '',
        pincode: ''
      });

      // Make customLocation required
      this.marketingForm.get('customLocation')?.setValidators([Validators.required]);

      // Make hierarchical fields optional
      this.marketingForm.get('state')?.clearValidators();
      this.marketingForm.get('city')?.clearValidators();
      this.marketingForm.get('locality')?.clearValidators();
      this.marketingForm.get('pincode')?.clearValidators();

      console.log('✅ Switched to MANUAL ENTRY mode');
    } else {
      // Clear custom location when switching to hierarchical
      this.marketingForm.patchValue({
        customLocation: ''
      });

      // Make hierarchical fields required again
      this.marketingForm.get('state')?.setValidators([Validators.required]);
      this.marketingForm.get('city')?.setValidators([Validators.required]);
      this.marketingForm.get('locality')?.setValidators([Validators.required]);
      this.marketingForm.get('pincode')?.setValidators([Validators.required]);

      // Make customLocation optional
      this.marketingForm.get('customLocation')?.clearValidators();

      console.log('✅ Switched to HIERARCHICAL DROPDOWN mode');
    }

    // Update validation status
    this.marketingForm.get('customLocation')?.updateValueAndValidity();
    this.marketingForm.get('state')?.updateValueAndValidity();
    this.marketingForm.get('city')?.updateValueAndValidity();
    this.marketingForm.get('locality')?.updateValueAndValidity();
    this.marketingForm.get('pincode')?.updateValueAndValidity();

    this.cdr.detectChanges();
  }

  // TrackBy functions for performance
  trackByTaskTypeId(index: number, taskType: any): number {
    return taskType.taskTypeId;
  }

  trackByLocationId(index: number, location: any): number {
    return location.locationId;
  }

  // Template getters
  get campaignManager() { return this.marketingForm.get('campaignManager'); }
  get employeeCode() { return this.marketingForm.get('employeeCode'); }
  get taskDescription() { return this.marketingForm.get('taskDescription'); }
  get taskDate() { return this.marketingForm.get('taskDate'); }
  get deadline() { return this.marketingForm.get('deadline'); }
  get priority() { return this.marketingForm.get('priority'); }
  get state() { return this.marketingForm.get('state'); }
  get city() { return this.marketingForm.get('city'); }
  get area() { return this.marketingForm.get('area'); }
  get locality() { return this.marketingForm.get('locality'); }
  get pincode() { return this.marketingForm.get('pincode'); }
  get clientName() { return this.marketingForm.get('clientName'); }
  get projectCode() { return this.marketingForm.get('projectCode'); }
  get consultantName() { return this.marketingForm.get('consultantName'); }
  get campCode() { return this.marketingForm.get('campCode'); }
  get consultantFeedback() { return this.marketingForm.get('consultantFeedback'); }

  // =============================================
  // DATABASE API METHODS FOR LOCALITIES AND PINCODES
  // =============================================

  private getUniqueLocalities(localities: any[]): any[] {
    const seen = new Set<string>();
    return localities.filter(loc => {
      const name = (loc.localityName || '').trim().toLowerCase();
      if (!name || seen.has(name)) return false;
      seen.add(name); return true;
    });
  }

  // Load all localities from database
  loadAllLocalitiesFromDatabase() {
    console.log('Loading all localities from database...');

    fetch(`${environment.apiUrl}/location/localities`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          const unique = this.getUniqueLocalities(data.data);
          this.localities = unique;
          this.filteredLocalities = unique;
          console.log('Localities loaded from database:', this.localities.length);
        } else {
          console.error('Error loading localities:', data.message);
          const fallback = this.getUniqueLocalities(this.localities);
          this.localities = fallback;
          this.filteredLocalities = fallback;
        }
      })
      .catch(error => {
        console.error('Error loading localities from database:', error);
        const fallback = this.getUniqueLocalities(this.localities);
        this.localities = fallback;
        this.filteredLocalities = fallback;
      });
  }

  // Search localities from database
  searchLocalitiesFromDatabase(searchTerm: string) {
    console.log('Searching localities in database with term:', searchTerm);

    fetch(`${environment.apiUrl}/location/localities/search?term=${encodeURIComponent(searchTerm)}`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.filteredLocalities = data.data;
          console.log('Filtered localities from database:', this.filteredLocalities.length);
        } else {
          console.error('Error searching localities:', data.message);
          // Fallback to local filtering
          this.filteredLocalities = this.localities.filter(locality =>
            locality.localityName && locality.localityName.toLowerCase().includes(searchTerm)
          );
        }
      })
      .catch(error => {
        console.error('Error searching localities from database:', error);
        // Fallback to local filtering
        this.filteredLocalities = this.localities.filter(locality =>
          locality.localityName && locality.localityName.toLowerCase().includes(searchTerm)
        );
      });
  }

  // Load all pincodes from database
  loadAllPincodesFromDatabase() {
    console.log('Loading all pincodes from database...');

    fetch(`${environment.apiUrl}/location/pincodes`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.allPincodeData = data.data;
          this.pincodes = data.data;
          this.filteredPincodes = data.data;
          console.log('Pincodes loaded from database:', this.allPincodeData.length);
        } else {
          console.error('Error loading pincodes:', data.message);
          this.loadComprehensivePincodes(); // Fallback to local data
        }
      })
      .catch(error => {
        console.error('Error loading pincodes from database:', error);
        this.loadComprehensivePincodes(); // Fallback to local data
      });
  }

  // Search pincodes from database
  searchPincodesFromDatabase(searchTerm: string) {
    console.log('Searching pincodes in database with term:', searchTerm);

    fetch(`${environment.apiUrl}/location/pincodes/search?term=${encodeURIComponent(searchTerm)}`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.filteredPincodes = data.data;
          console.log('Filtered pincodes from database:', this.filteredPincodes.length);
        } else {
          console.error('Error searching pincodes:', data.message);
          // Fallback to local filtering
          this.filteredPincodes = this.allPincodeData.filter(pincode =>
            pincode.pincode.toString().includes(searchTerm) ||
            pincode.localityName.toLowerCase().includes(searchTerm)
          );
        }
      })
      .catch(error => {
        console.error('Error searching pincodes from database:', error);
        // Fallback to local filtering
        this.filteredPincodes = this.allPincodeData.filter(pincode =>
          pincode.pincode.toString().includes(searchTerm) ||
          pincode.localityName.toLowerCase().includes(searchTerm)
        );
      });
  }

  // Load pincodes for specific locality from database
  loadPincodesForLocalityFromDatabase(localityName: string) {
    console.log('Loading pincodes for locality from database:', localityName);

    fetch(`${environment.apiUrl}/location/pincodes/by-locality?locality=${encodeURIComponent(localityName)}`)
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.pincodes = data.data;
          this.filteredPincodes = data.data;
          console.log('Pincodes loaded for locality from database:', this.pincodes.length);

          // Auto-select the first pincode if only one exists
          if (this.pincodes.length === 1) {
            this.marketingForm.patchValue({ pincode: this.pincodes[0].pincode });
            console.log('Auto-selected pincode from database:', this.pincodes[0].pincode);
          }
        } else {
          console.error('Error loading pincodes for locality:', data.message);
          this.loadPincodesForLocality(localityName); // Fallback to local data
        }
      })
      .catch(error => {
        console.error('Error loading pincodes for locality from database:', error);
        this.loadPincodesForLocality(localityName); // Fallback to local data
      });
  }

  currentDateTime: string = '';

  private updateCurrentDateTime() {
    const now = new Date();
    this.currentDateTime = now.toLocaleString('en-US', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    });
  }

  getCurrentDateTime(): string {
    return this.currentDateTime;
  }

  // ⭐⭐⭐ NEW LOCATION METHODS FROM ADMIN-TASK-MODAL ⭐⭐⭐
  // These methods provide working State → City → Locality → Pincode cascade

  onStateChange(stateId: any): void {
    const stateIdNum = Number(stateId);
    console.log('🔍 STATE CHANGED TO:', stateIdNum);

    if (!stateIdNum) {
      this.cities = [];
      this.localitySuggestions = [];
      this.pincodeOptions = [];
      this.marketingForm.patchValue({
        city: '',
        locality: '',
        pincode: ''
      });
      console.log('⚠️ State cleared, cities reset');
      return;
    }

    // Reset dependent fields
    this.localitySuggestions = [];
    this.pincodeOptions = [];
    this.selectedStateId = stateIdNum;
    this.marketingForm.patchValue({
      city: '',
      locality: '',
      pincode: ''
    });

    console.log('📡 Fetching cities for stateId:', stateIdNum);
    this.locationService.getCitiesByState(stateIdNum).subscribe({
      next: cities => {
        console.log('🏙️ CITIES LOADED:', cities);
        this.cities = cities;
        this.cdr.detectChanges();
        console.log('✅ Cities dropdown should now show', this.cities.length, 'cities');
      },
      error: err => {
        console.error('❌ ERROR loading cities:', err);
        this.cities = [];
      }
    });
  }

  onCityChange(cityId: any): void {
    const cityIdNum = Number(cityId);
    console.log('🏙️ CITY CHANGED TO:', cityIdNum);

    if (!cityIdNum) {
      this.localitySuggestions = [];
      this.marketingForm.patchValue({
        locality: '',
        pincode: ''
      });
      this.pincodeOptions = [];
      console.log('⚠️ City cleared, localities reset');
      return;
    }

    this.selectedCityId = cityIdNum;
    this.marketingForm.patchValue({
      locality: '',
      pincode: ''
    });

    console.log('📡 Fetching localities for cityId:', cityIdNum);
    this.locationHierarchyService.getLocalitiesByCity(cityIdNum).subscribe({
      next: localities => {
        console.log('🏘️ LOCALITIES LOADED:', localities);
        // Store as string array for dropdown
        this.localitySuggestions = localities.map((l: any) => l.name);
        // Also store full objects for ID lookup
        (this as any).localityObjects = localities;
        this.cdr.detectChanges();
        console.log('✅ Localities dropdown should now show', this.localitySuggestions.length, 'localities');
      },
      error: err => {
        console.error('❌ ERROR loading localities:', err);
        this.localitySuggestions = [];
      }
    });
  }

  onLocalityChange(localityName: any): void {
    console.log('🏘️ LOCALITY CHANGED TO:', localityName);

    if (!localityName) {
      this.pincodeOptions = [];
      this.marketingForm.patchValue({
        pincode: ''
      });
      console.log('⚠️ Locality cleared, pincodes reset');
      return;
    }

    // Find the locality object to get its ID
    const localityObjects = (this as any).localityObjects || [];
    const selectedLocality = localityObjects.find((l: any) => l.name === localityName);

    console.log('🔍 Looking for locality object:', localityName, 'in', localityObjects);
    console.log('✅ Found locality:', selectedLocality);

    if (selectedLocality) {
      const localityId = selectedLocality.id;

      console.log('📡 Fetching pincodes for localityId:', localityId);
      // Fetch pincodes using the locality ID
      this.locationHierarchyService.getPincodesByLocality(localityId).subscribe({
        next: pincodes => {
          console.log('📮 PINCODES LOADED:', pincodes);
          // Extract pincode values as strings
          this.pincodeOptions = pincodes.map((p: any) => p.value || p.pincode);
          this.cdr.detectChanges();

          // ⭐⭐⭐ AUTO-SELECT IF ONLY ONE PINCODE! ⭐⭐⭐
          if (this.pincodeOptions.length === 1) {
            this.marketingForm.patchValue({ pincode: this.pincodeOptions[0] });
            console.log('✅✅✅ AUTO-SELECTED PINCODE:', this.pincodeOptions[0]);
          }

          console.log('✅ Pincodes dropdown should now show', this.pincodeOptions.length, 'pincodes');
        },
        error: err => {
          console.error('❌ ERROR loading pincodes:', err);
          this.pincodeOptions = [];
        }
      });
    } else {
      console.warn('⚠️ Locality object not found for:', localityName);
    }
  }

  onManualToggle(): void {
    this.manualLocationEntry = !this.manualLocationEntry;
    console.log('🔄 Manual entry toggled:', this.manualLocationEntry);
    // Reset all location fields when toggling
    if (this.manualLocationEntry) {
      this.marketingForm.patchValue({
        state: '',
        city: '',
        locality: '',
        pincode: ''
      });
    }
  }

  // Helper methods for displaying location names
  getStateName(stateId: any): string {
    const state = this.states.find(s => s.id === Number(stateId));
    return state ? state.name : '';
  }


  getCityName(cityId: any): string {
    const city = this.cities.find(c => c.id === Number(cityId));
    return city ? city.name : '';
  }

}


