# Marketing Campaign Form

This component provides a comprehensive form for creating and managing marketing campaigns for Action Medical Institute & Action Cancer Hospital.

## Features

- **Campaign Information**: Basic details like campaign name, dates, budget, and priority
- **Campaign Type & Target Audience**: Multi-select options for campaign types and target audiences
- **Location Selection**: Hierarchical location selection (State > City > Area > Pincode)
- **Campaign Goals & Metrics**: Fields for expected reach, conversion goals, and KPIs
- **Project & Client Information**: Client details, project codes, and department information
- **Marketing Materials & Approvals**: Required materials and approval workflow
- **Form Validation**: Comprehensive validation for required fields

## Usage

1. Navigate to the Marketing Form from the Admin Dashboard
2. Fill in the required fields (marked with *)
3. Select campaign types and target audiences
4. Choose locations using the hierarchical selector
5. Add campaign goals and metrics
6. Submit the form to create a new marketing campaign

## Integration

The form integrates with the existing task management system by:

1. Using the same hierarchical location selector component
2. Leveraging the employee selection dropdown
3. Submitting data through the TaskService
4. Storing campaign data in the Tasks table with additional metadata

## Database Structure

The form utilizes the following database tables:

- **Tasks**: Core campaign data
- **States/Areas/Pincodes**: Location hierarchy
- **Employees**: Campaign manager assignment

## Form Fields

| Field | Description | Required |
|-------|-------------|----------|
| Campaign Manager | Employee responsible for the campaign | Yes |
| Campaign Name | Name of the marketing campaign | Yes |
| Start Date | Campaign start date | Yes |
| End Date | Campaign end date | Yes |
| Budget | Campaign budget in rupees | Yes |
| Priority | Campaign priority (Low/Medium/High) | Yes |
| Campaign Type | Type of marketing campaign (multi-select) | No |
| Target Audience | Target demographic (multi-select) | No |
| Location | Hierarchical location selection | Yes |
| Expected Reach | Estimated audience reach | No |
| Conversion Goal | Target conversion rate or metric | No |
| KPIs | Key performance indicators | No |
| Client/Department | Client or department name | No |
| Project Code | Unique project identifier | No |
| Budget Code | Budget allocation code | No |
| Department Code | Department identifier | No |
| Marketing Materials | Required marketing materials | No |
| Approval Required | Whether approval is needed before launch | No |
| Approval Contact | Person who needs to approve | No |
| Description | Campaign objectives and details | Yes |
| Additional Notes | Any extra information | No |

## Component Structure

- **marketing-form.component.ts**: Main component logic
- **marketing-form.component.html**: Form template
- **marketing-form.component.css**: Styling

## Dependencies

- HierarchicalLocationSelectorComponent
- SearchableDropdownComponent
- TaskService
- EmployeeService
- LocationService
- NotificationService