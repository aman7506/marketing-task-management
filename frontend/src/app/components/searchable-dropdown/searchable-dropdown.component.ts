import { Component, Input, Output, EventEmitter, OnInit, OnDestroy, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { Subject, BehaviorSubject, combineLatest } from 'rxjs';
import { debounceTime, distinctUntilChanged, map, startWith } from 'rxjs/operators';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

export interface DropdownOption {
  value: any;
  label: string;
  disabled?: boolean;
  group?: string;
}

@Component({
  selector: 'app-searchable-dropdown',
  templateUrl: './searchable-dropdown.component.html',
  styleUrls: ['./searchable-dropdown.component.css'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => SearchableDropdownComponent),
      multi: true
    }
  ]
})
export class SearchableDropdownComponent implements OnInit, OnDestroy, ControlValueAccessor {
  @Input() options: DropdownOption[] = [];
  @Input() placeholder = 'Select an option...';
  @Input() searchPlaceholder = 'Search...';
  @Input() multiple = false;
  @Input() disabled = false;   // ✅ Already defined, safe to bind
  @Input() readonly = false;  // New input for readonly mode (view-only)
  @Input() clearable = true;
  @Input() maxHeight = '200px';
  @Input() loading = false;
  @Input() noOptionsText = 'No options found';
  @Input() allowCustomValue = false;
  @Input() customValueText = 'Add "{searchTerm}"';
  @Input() id = ''; // Add id input for accessibility

  @Output() selectionChange = new EventEmitter<any>();
  @Output() searchChange = new EventEmitter<string>();
  @Output() customValueAdd = new EventEmitter<string>();

  // Internal state
  isOpen = false;
  searchTerm = '';
  selectedValues: any[] = [];
  filteredOptions: DropdownOption[] = [];
  highlightedIndex = -1;

  // Subjects for reactive programming
  public searchSubject = new Subject<string>();
  private optionsSubject = new BehaviorSubject<DropdownOption[]>([]);
  private destroy$ = new Subject<void>();

  // ControlValueAccessor implementation
  private onChange = (value: any) => {};
  private onTouched = () => {};

  constructor() {
    // Setup reactive search
    combineLatest([
      this.searchSubject.pipe(
        startWith(''),
        debounceTime(300),
        distinctUntilChanged()
      ),
      this.optionsSubject.asObservable()
    ]).pipe(
      map(([search, options]) => this.filterOptions(search, options))
    ).subscribe(filtered => {
      this.filteredOptions = filtered;
      this.highlightedIndex = -1;
    });
  }

  ngOnInit() {
    this.optionsSubject.next(this.options);
    // Ensure disabled state is properly applied
    this.setDisabledState(this.disabled);
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }

  // ControlValueAccessor methods
  writeValue(value: any): void {
    if (this.multiple) {
      this.selectedValues = Array.isArray(value) ? value : [];
    } else {
      this.selectedValues = value !== null && value !== undefined ? [value] : [];
    }
  }

  registerOnChange(fn: any): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: any): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  // Public methods
  toggleDropdown() {
    if (this.disabled || this.readonly) return;

    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.searchTerm = '';
      this.searchSubject.next('');
      setTimeout(() => {
        const searchInput = document.querySelector('.dropdown-search input') as HTMLInputElement;
        if (searchInput) {
          searchInput.focus();
        }
      }, 100);
    }
  }

  closeDropdown() {
    this.isOpen = false;
    this.searchTerm = '';
    this.highlightedIndex = -1;
    this.onTouched();
  }

  clearSearch() {
    this.searchTerm = '';
    this.searchSubject.next('');
  }

  onSearchInput(event: Event) {
    const target = event.target as HTMLInputElement;
    this.searchTerm = target.value;
    this.searchSubject.next(this.searchTerm);
    this.searchChange.emit(this.searchTerm);
  }

  selectOption(option: DropdownOption) {
    if (option.disabled) return;

    if (this.multiple) {
      const index = this.selectedValues.findIndex(v => v === option.value);
      if (index > -1) {
        this.selectedValues.splice(index, 1);
      } else {
        this.selectedValues.push(option.value);
      }
      this.onChange([...this.selectedValues]);
    } else {
      this.selectedValues = [option.value];
      this.onChange(option.value);
      this.closeDropdown();
    }

    this.selectionChange.emit(this.multiple ? [...this.selectedValues] : option.value);
  }

  removeSelection(value: any, event?: Event) {
    if (event) event.stopPropagation();

    if (this.multiple) {
      const index = this.selectedValues.findIndex(v => v === value);
      if (index > -1) {
        this.selectedValues.splice(index, 1);
        this.onChange([...this.selectedValues]);
        this.selectionChange.emit([...this.selectedValues]);
      }
    } else {
      this.selectedValues = [];
      this.onChange(null);
      this.selectionChange.emit(null);
    }
  }

  clearAll(event: Event) {
    event.stopPropagation();
    this.selectedValues = [];
    this.onChange(this.multiple ? [] : null);
    this.selectionChange.emit(this.multiple ? [] : null);
  }

  addCustomValue() {
    if (this.allowCustomValue && this.searchTerm.trim()) {
      this.customValueAdd.emit(this.searchTerm.trim());
      this.searchTerm = '';
      this.searchSubject.next('');
    }
  }

  // Keyboard navigation
  onKeyDown(event: KeyboardEvent) {
    if (!this.isOpen) {
      if (event.key === 'Enter' || event.key === ' ' || event.key === 'ArrowDown') {
        event.preventDefault();
        this.toggleDropdown();
      }
      return;
    }

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        this.highlightedIndex = Math.min(this.highlightedIndex + 1, this.filteredOptions.length - 1);
        this.scrollToHighlighted();
        break;
      case 'ArrowUp':
        event.preventDefault();
        this.highlightedIndex = Math.max(this.highlightedIndex - 1, -1);
        this.scrollToHighlighted();
        break;
      case 'Enter':
        event.preventDefault();
        if (this.highlightedIndex >= 0 && this.highlightedIndex < this.filteredOptions.length) {
          this.selectOption(this.filteredOptions[this.highlightedIndex]);
        } else if (this.allowCustomValue && this.searchTerm.trim()) {
          this.addCustomValue();
        }
        break;
      case 'Escape':
        event.preventDefault();
        this.closeDropdown();
        break;
    }
  }

  // Helper methods
  private filterOptions(search: string, options: DropdownOption[]): DropdownOption[] {
    if (!search.trim()) return options;

    const searchLower = search.toLowerCase();
    return options.filter(option => 
      option.label.toLowerCase().includes(searchLower) ||
      (option.value && option.value.toString().toLowerCase().includes(searchLower))
    );
  }

  private scrollToHighlighted() {
    setTimeout(() => {
      const highlighted = document.querySelector('.dropdown-option.highlighted') as HTMLElement;
      if (highlighted) {
        highlighted.scrollIntoView({ block: 'nearest' });
      }
    });
  }

  isSelected(value: any): boolean {
    return this.selectedValues.includes(value);
  }

  getSelectedLabels(): string[] {
    return this.selectedValues.map(value => {
      const option = this.options.find(opt => opt.value === value);
      return option ? option.label : value.toString();
    });
  }

  getDisplayText(): string {
    if (this.selectedValues.length === 0) return this.placeholder;

    if (this.multiple) {
      const labels = this.getSelectedLabels();
      return labels.length === 1 ? labels[0] : `${labels.length} items selected`;
    } else {
      return this.getSelectedLabels()[0] || this.placeholder;
    }
  }

  ngOnChanges() {
    this.optionsSubject.next(this.options);
  }

  highlightSearchTerm(text: string): string {
    if (!this.searchTerm.trim()) return text;

    const searchRegex = new RegExp(`(${this.searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    return text.replace(searchRegex, '<span class="highlight">$1</span>');
  }
}
