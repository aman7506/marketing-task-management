using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace MarketingForm.Services
{
    public class MarketingCampaignService
    {
        private readonly string _connectionString;
        private readonly IConfiguration _configuration;

        public MarketingCampaignService(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<CampaignSaveResult> SaveMarketingCampaignAsync(MarketingCampaignData campaignData)
        {
            var result = new CampaignSaveResult();

            try
            {
                int? stateId = campaignData.StateId;
                int? cityId = campaignData.CityId;
                string? localityName = campaignData.Locality;
                string? stateName = campaignData.StateName;
                string? cityName = campaignData.CityName;
                string? pincodeValue = campaignData.Pincode;
                int? pincodeId = campaignData.PincodeId;
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    if (!stateId.HasValue && !string.IsNullOrEmpty(stateName)) {
                        var stateCmd = new SqlCommand("IF EXISTS (SELECT 1 FROM States WHERE StateName=@StateName) SELECT StateId FROM States WHERE StateName=@StateName ELSE BEGIN INSERT INTO States (StateName) OUTPUT INSERTED.StateId VALUES (@StateName) END", connection);
                        stateCmd.Parameters.AddWithValue("@StateName", stateName);
                        stateId = (int?) await stateCmd.ExecuteScalarAsync();
                    }
                    if (!cityId.HasValue && !string.IsNullOrEmpty(cityName) && stateId.HasValue) {
                        var cityCmd = new SqlCommand("IF EXISTS (SELECT 1 FROM Cities WHERE CityName=@CityName AND StateId=@StateId) SELECT CityId FROM Cities WHERE CityName=@CityName AND StateId=@StateId ELSE BEGIN INSERT INTO Cities (CityName, StateId) OUTPUT INSERTED.CityId VALUES (@CityName, @StateId) END", connection);
                        cityCmd.Parameters.AddWithValue("@CityName", cityName);
                        cityCmd.Parameters.AddWithValue("@StateId", stateId);
                        cityId = (int?) await cityCmd.ExecuteScalarAsync();
                    }
                    
                    // ⭐ COMMENTED OUT - This was causing "State column NULL" error
                    // Locations table requires State column but we're only inserting LocationName and CityId
                    // Frontend should send localityId from dropdown instead
                    /*
                    if (!string.IsNullOrEmpty(localityName) && cityId.HasValue) {
                        var locCmd = new SqlCommand("IF EXISTS (SELECT 1 FROM Locations WHERE LocationName=@LocalityName AND CityId=@CityId) SELECT LocationId FROM Locations WHERE LocationName=@LocalityName AND CityId=@CityId ELSE BEGIN INSERT INTO Locations (LocationName, CityId) OUTPUT INSERTED.LocationId VALUES (@LocalityName, @CityId) END", connection);
                        locCmd.Parameters.AddWithValue("@LocalityName", localityName);
                        locCmd.Parameters.AddWithValue("@CityId", cityId);
                        var locationId = (int?) await locCmd.ExecuteScalarAsync();
                        campaignData.LocalityId = locationId;
                    }
                    */
                    
                    if (!pincodeId.HasValue && !string.IsNullOrEmpty(pincodeValue)) {
                        var pinCmd = new SqlCommand("IF EXISTS (SELECT 1 FROM Pincodes WHERE Pincode=@PincodeValue) SELECT PincodeId FROM Pincodes WHERE Pincode =@PincodeValue ELSE BEGIN INSERT INTO Pincodes (Pincode) OUTPUT INSERTED.PincodeId VALUES (@PincodeValue) END", connection);
                        pinCmd.Parameters.AddWithValue("@PincodeValue", pincodeValue);
                        pincodeId = (int?) await pinCmd.ExecuteScalarAsync();
                    }

                    // ⭐ AUTO-GENERATE CAMPAIGN CODE IF NOT PROVIDED
                    if (string.IsNullOrEmpty(campaignData.CampaignCode))
                    {
                        campaignData.CampaignCode = await GetNextCampaignCodeAsync();
                    }

                    using (var command = new SqlCommand("sp_save_marketing_campaign", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Add parameters
                        command.Parameters.AddWithValue("@CampaignManager", campaignData.CampaignManager ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@EmployeeCode", campaignData.EmployeeCode ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@TaskDescription", campaignData.TaskDescription ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@TaskDate", campaignData.TaskDate);
                        command.Parameters.AddWithValue("@Deadline", campaignData.Deadline);
                        command.Parameters.AddWithValue("@Priority", campaignData.Priority ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@IsUrgent", campaignData.IsUrgent);

                        // Location parameters
                        command.Parameters.AddWithValue("@StateId", stateId);
                        command.Parameters.AddWithValue("@CityId", cityId);
                        command.Parameters.AddWithValue("@Locality", localityName);
                        command.Parameters.AddWithValue("@Pincode", pincodeValue);
                        command.Parameters.AddWithValue("@LocalityId", campaignData.LocalityId);
                        command.Parameters.AddWithValue("@PincodeId", pincodeId);

                        // Project & Client parameters
                        command.Parameters.AddWithValue("@ClientName", campaignData.ClientName ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@ProjectCode", campaignData.ProjectCode ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@ConsultantName", campaignData.ConsultantName ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@CampaignCode", campaignData.CampaignCode ?? (object)DBNull.Value);

                        // Campaign details parameters
                        command.Parameters.AddWithValue("@EstimatedHours", campaignData.EstimatedHours ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@ExpectedReach", campaignData.ExpectedReach ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@ConversionGoal", campaignData.ConversionGoal ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@KPIs", campaignData.KPIs ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@MarketingMaterials", campaignData.MarketingMaterials ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@ApprovalRequired", campaignData.ApprovalRequired);
                        command.Parameters.AddWithValue("@ApprovalContact", campaignData.ApprovalContact ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@BudgetCode", campaignData.BudgetCode ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@AdditionalNotes", campaignData.AdditionalNotes ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@ConsultantFeedback", campaignData.ConsultantFeedback ?? (object)DBNull.Value);

                        // Convert selected task types to JSON
                        var taskTypesJson = JsonConvert.SerializeObject(campaignData.SelectedTaskTypes ?? new int[0]);
                        command.Parameters.AddWithValue("@SelectedTaskTypes", taskTypesJson);

                        // Output parameters
                        var campaignIdParam = new SqlParameter("@CampaignId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(campaignIdParam);

                        var successParam = new SqlParameter("@Success", SqlDbType.Bit)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(successParam);

                        var messageParam = new SqlParameter("@Message", SqlDbType.NVarChar, 500)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(messageParam);

                        // Execute stored procedure
                        await command.ExecuteNonQueryAsync();

                        // Get output parameters
                        result.CampaignId = (int)campaignIdParam.Value;
                        result.Success = (bool)successParam.Value;
                        result.Message = messageParam.Value?.ToString() ?? string.Empty;
                    }
                }
            }
            catch (Exception ex)
            {
                // 🔍 LOG DATABASE ERROR
                Console.WriteLine("❌❌❌ DATABASE SAVE ERROR ❌❌❌");
                Console.WriteLine($"Error Message: {ex.Message}");
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                Console.WriteLine("==========================================");
                
                result.Success = false;
                result.Message = $"Error saving marketing campaign: {ex.Message}";
                result.CampaignId = 0;
            }

            return result;
        }

        public async Task<string> GetNextCampaignCodeAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_generate_campaign_code", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Output parameter for campaign code
                        var campaignCodeParam = new SqlParameter("@CampaignCode", SqlDbType.NVarChar, 50)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(campaignCodeParam);

                        // Execute stored procedure
                        await command.ExecuteNonQueryAsync();

                        // Get the generated campaign code
                        string campaignCode = campaignCodeParam.Value?.ToString() ?? string.Empty;

                        return campaignCode;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error generating campaign code: {ex.Message}");
            }
        }

        public async Task<MarketingCampaignData> GetCampaignByIdAsync(int campaignId)
        {
            var campaign = new MarketingCampaignData();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("SELECT * FROM MarketingCampaigns WHERE CampaignId = @CampaignId", connection))
                    {
                        command.Parameters.AddWithValue("@CampaignId", campaignId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                campaign = MapReaderToCampaign(reader);
                            }
                        }
                    }

                    // Get task types for this campaign
                    using (var command = new SqlCommand(
                        "SELECT tt.TaskTypeId, tt.TypeName " +
                        "FROM CampaignTaskTypes ctt " +
                        "INNER JOIN TaskTypes tt ON ctt.TaskTypeId = tt.TaskTypeId " +
                        "WHERE ctt.CampaignId = @CampaignId", connection))
                    {
                        command.Parameters.AddWithValue("@CampaignId", campaignId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            var taskTypes = new List<int>();
                            while (await reader.ReadAsync())
                            {
                                taskTypes.Add(reader.GetInt32("TaskTypeId"));
                            }
                            campaign.SelectedTaskTypes = taskTypes.ToArray();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle error
                throw new Exception($"Error retrieving campaign: {ex.Message}");
            }

            return campaign;
        }

        private MarketingCampaignData MapReaderToCampaign(SqlDataReader reader)
        {
            return new MarketingCampaignData
            {
                CampaignId = reader.GetInt32("CampaignId"),
                CampaignManager = reader["CampaignManager"]?.ToString() ?? string.Empty,
                EmployeeCode = reader["EmployeeCode"]?.ToString() ?? string.Empty,
                TaskDescription = reader["TaskDescription"]?.ToString() ?? string.Empty,
                TaskDate = reader.GetDateTime("TaskDate"),
                Deadline = reader.GetDateTime("Deadline"),
                Priority = reader["Priority"]?.ToString() ?? string.Empty,
                IsUrgent = reader.GetBoolean("IsUrgent"),
                StateId = reader["StateId"] != DBNull.Value ? reader.GetInt32("StateId") : 0,
                CityId = reader["CityId"] != DBNull.Value ? reader.GetInt32("CityId") : 0,
                Locality = reader["Locality"]?.ToString() ?? string.Empty,
                Pincode = reader["Pincode"]?.ToString() ?? string.Empty,
                ClientName = reader["ClientName"]?.ToString() ?? string.Empty,
                ProjectCode = reader["ProjectCode"]?.ToString() ?? string.Empty,
                ConsultantName = reader["ConsultantName"]?.ToString() ?? string.Empty,
                CampaignCode = reader["CampaignCode"]?.ToString() ?? string.Empty,
                EstimatedHours = reader["EstimatedHours"] != DBNull.Value ? reader.GetDecimal("EstimatedHours") : null,
                ExpectedReach = reader["ExpectedReach"] != DBNull.Value ? reader.GetInt32("ExpectedReach") : null,
                ConversionGoal = reader["ConversionGoal"]?.ToString() ?? string.Empty,
                KPIs = reader["KPIs"]?.ToString() ?? string.Empty,
                MarketingMaterials = reader["MarketingMaterials"]?.ToString() ?? string.Empty,
                ApprovalRequired = reader.GetBoolean("ApprovalRequired"),
                ApprovalContact = reader["ApprovalContact"]?.ToString() ?? string.Empty,
                BudgetCode = reader["BudgetCode"]?.ToString() ?? string.Empty,
                AdditionalNotes = reader["AdditionalNotes"]?.ToString() ?? string.Empty,
                ConsultantFeedback = reader["ConsultantFeedback"]?.ToString() ?? string.Empty,
                Status = reader["Status"]?.ToString() ?? string.Empty,
                CreatedAt = reader.GetDateTime("CreatedAt"),
                UpdatedAt = reader.GetDateTime("UpdatedAt")
            };
        }

        public async Task<List<MarketingCampaignData>> GetAllCampaignsAsync()
        {
            var campaigns = new List<MarketingCampaignData>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    var query = @"
                        SELECT 
                            CampaignId, CampaignManager, EmployeeCode, TaskDescription,
                            TaskDate, Deadline, Priority, IsUrgent,
                            StateId, CityId, Locality, Pincode,
                            ClientName, ProjectCode, ConsultantName, CampaignCode,
                            EstimatedHours, ExpectedReach, ConversionGoal, KPIs,
                            MarketingMaterials, ApprovalRequired, ApprovalContact,
                            BudgetCode, AdditionalNotes, ConsultantFeedback, Status,
                            CreatedAt, UpdatedAt
                        FROM MarketingCampaigns 
                        ORDER BY CreatedAt DESC";

                    using (var command = new SqlCommand(query, connection))
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                campaigns.Add(MapReaderToCampaign(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error retrieving campaigns: {ex.Message}");
                throw;
            }

            return campaigns;
        }
    }

    public class MarketingCampaignData
    {
        public int CampaignId { get; set; }
        public string CampaignManager { get; set; } = string.Empty;
        public string? EmployeeCode { get; set; }  // Nullable
        public string TaskDescription { get; set; } = string.Empty;
        public DateTime TaskDate { get; set; }
        public DateTime Deadline { get; set; }
        public string Priority { get; set; } = string.Empty;
        public bool IsUrgent { get; set; }
        public int StateId { get; set; }
        public int CityId { get; set; }
        public string? Locality { get; set; }  // Nullable
        public string? Pincode { get; set; }  // Nullable
        public string? ClientName { get; set; }  // Nullable
        public string? ProjectCode { get; set; }  // Nullable
        public string? ConsultantName { get; set; }  // Nullable
        public string? CampaignCode { get; set; }  // ⭐ NULLABLE - Auto-generated if null
        public decimal? EstimatedHours { get; set; }
        public int? ExpectedReach { get; set; }
        public string? ConversionGoal { get; set; }  // Nullable
        public string? KPIs { get; set; }  // Nullable
        public string? MarketingMaterials { get; set; }  // Nullable
        public bool ApprovalRequired { get; set; }
        public string? ApprovalContact { get; set; }  // Nullable
        public string? BudgetCode { get; set; }  // Nullable
        public string? AdditionalNotes { get; set; }  // Nullable
        public string? ConsultantFeedback { get; set; }  // ⭐ NULLABLE
        public int[] SelectedTaskTypes { get; set; } = Array.Empty<int>();
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int? LocalityId { get; set; }
        public int? PincodeId { get; set; }
        public string? StateName { get; set; }
        public string? CityName { get; set; }
    }

    public class CampaignSaveResult
    {
        public int CampaignId { get; set; }
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
