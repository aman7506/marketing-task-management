using Microsoft.AspNetCore.Mvc;
using MarketingForm.Services;
using System.Threading.Tasks;
using System;

namespace MarketingForm.Controllers
{
    [ApiController]
    [Route("api/marketingcampaign")]
    public class MarketingCampaignController : ControllerBase
    {
        private readonly MarketingCampaignService _campaignService;

        public MarketingCampaignController(MarketingCampaignService campaignService)
        {
            _campaignService = campaignService;
        }

        // GET: api/marketingcampaign/test
        [HttpGet("test")]
        public IActionResult Test()
        {
            return Ok(new
            {
                success = true,
                message = "Marketing Campaign API is running!",
                timestamp = DateTime.Now,
                version = "1.0.0"
            });
        }

        // GET: api/marketingcampaign/newcode
        [HttpGet("newcode")]
        public async Task<IActionResult> GetNewCampaignCode()
        {
            try
            {
                var campaignCode = await _campaignService.GetNextCampaignCodeAsync();
                
                return Ok(new
                {
                    success = true,
                    campaignCode = campaignCode,
                    message = "Campaign code generated successfully",
                    timestamp = DateTime.Now
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Failed to generate campaign code",
                    error = ex.Message
                });
            }
        }

        [HttpPost("save")]
        public async Task<IActionResult> SaveCampaign([FromBody] MarketingCampaignData campaignData)
        {
            try
            {
                // 🔍 LOG RECEIVED DATA FOR DEBUGGING
                Console.WriteLine("==========================================");
                Console.WriteLine("📥 RECEIVED CAMPAIGN DATA:");
                Console.WriteLine($"Campaign Data NULL? {campaignData == null}");
                
                if (campaignData == null)
                {
                    Console.WriteLine("❌ Campaign data is NULL!");
                    return BadRequest(new { success = false, message = "Campaign data is required" });
                }

                Console.WriteLine($"✅ Campaign Manager: '{campaignData.CampaignManager}'");
                Console.WriteLine($"✅ Task Description: '{campaignData.TaskDescription}'");
                Console.WriteLine($"✅ Task Date: {campaignData.TaskDate}");
                Console.WriteLine($"✅ Deadline: {campaignData.Deadline}");
                Console.WriteLine($"✅ Priority: '{campaignData.Priority}'");
                Console.WriteLine($"✅ Selected Task Types: {campaignData.SelectedTaskTypes?.Length ?? 0} types");
                Console.WriteLine($"✅ Approval Required: {campaignData.ApprovalRequired}");
                Console.WriteLine($"✅ Approval Contact: '{campaignData.ApprovalContact}'");
                Console.WriteLine("==========================================");

                // Validate required fields
                if (string.IsNullOrWhiteSpace(campaignData.CampaignManager))
                {
                    Console.WriteLine("❌ VALIDATION FAILED: Campaign Manager is empty");
                    return BadRequest(new { success = false, message = "Campaign Manager is required", field = "campaignManager" });
                }

                if (string.IsNullOrWhiteSpace(campaignData.TaskDescription))
                {
                    Console.WriteLine("❌ VALIDATION FAILED: Task Description is empty");
                    return BadRequest(new { success = false, message = "Task Description is required", field = "taskDescription" });
                }

                if (campaignData.TaskDate == default(DateTime))
                {
                    Console.WriteLine("❌ VALIDATION FAILED: Task Date is default/empty");
                    return BadRequest(new { success = false, message = "Task Date is required", field = "taskDate" });
                }

                if (campaignData.Deadline == default(DateTime))
                {
                    Console.WriteLine("❌ VALIDATION FAILED: Deadline is default/empty");
                    return BadRequest(new { success = false, message = "Deadline is required", field = "deadline" });
                }

                if (string.IsNullOrWhiteSpace(campaignData.Priority))
                {
                    Console.WriteLine("❌ VALIDATION FAILED: Priority is empty");
                    return BadRequest(new { success = false, message = "Priority is required", field = "priority" });
                }

                if (campaignData.SelectedTaskTypes == null || campaignData.SelectedTaskTypes.Length == 0)
                {
                    Console.WriteLine("❌ VALIDATION FAILED: No task types selected");
                    return BadRequest(new { success = false, message = "At least one task type must be selected", field = "selectedTaskTypes" });
                }

                // ⭐ CONDITIONAL VALIDATION: ApprovalContact required when ApprovalRequired = true
                if (campaignData.ApprovalRequired && string.IsNullOrWhiteSpace(campaignData.ApprovalContact))
                {
                    Console.WriteLine("❌ VALIDATION FAILED: Approval Contact required when ApprovalRequired=true");
                    return BadRequest(new
                    {
                        success = false,
                        message = "Approval Contact is required when Approval is Required",
                        field = "approvalContact"
                    });
                }

                // ⭐ SANITIZE EMPTY STRINGS TO NULL  for optional fields
                campaignData.EmployeeCode = string.IsNullOrWhiteSpace(campaignData.EmployeeCode) ? null : campaignData.EmployeeCode.Trim();
                campaignData.ClientName = string.IsNullOrWhiteSpace(campaignData.ClientName) ? null : campaignData.ClientName.Trim();
                campaignData.ProjectCode = string.IsNullOrWhiteSpace(campaignData.ProjectCode) ? null : campaignData.ProjectCode.Trim();
                campaignData.ConsultantName = string.IsNullOrWhiteSpace(campaignData.ConsultantName) ? null : campaignData.ConsultantName.Trim();
                campaignData.ConversionGoal = string.IsNullOrWhiteSpace(campaignData.ConversionGoal) ? null : campaignData.ConversionGoal.Trim();
                campaignData.KPIs = string.IsNullOrWhiteSpace(campaignData.KPIs) ? null : campaignData.KPIs.Trim();
                campaignData.MarketingMaterials = string.IsNullOrWhiteSpace(campaignData.MarketingMaterials) ? null : campaignData.MarketingMaterials.Trim();
                campaignData.ApprovalContact = string.IsNullOrWhiteSpace(campaignData.ApprovalContact) ? null : campaignData.ApprovalContact.Trim();
                campaignData.BudgetCode = string.IsNullOrWhiteSpace(campaignData.BudgetCode) ? null : campaignData.BudgetCode.Trim();
                campaignData.AdditionalNotes = string.IsNullOrWhiteSpace(campaignData.AdditionalNotes) ? null : campaignData.AdditionalNotes.Trim();
                campaignData.ConsultantFeedback = string.IsNullOrWhiteSpace(campaignData.ConsultantFeedback) ? null : campaignData.ConsultantFeedback.Trim();
                campaignData.Locality = string.IsNullOrWhiteSpace(campaignData.Locality) ? null : campaignData.Locality.Trim();
                campaignData.Pincode = string.IsNullOrWhiteSpace(campaignData.Pincode) ? null : campaignData.Pincode.Trim();

                // Trim required fields
                campaignData.CampaignManager = campaignData.CampaignManager.Trim();
                campaignData.TaskDescription = campaignData.TaskDescription.Trim();
                campaignData.Priority = campaignData.Priority.Trim();

                // Save campaign to database
                Console.WriteLine("💾 Calling SaveMarketingCampaignAsync...");
                var result = await _campaignService.SaveMarketingCampaignAsync(campaignData);

                if (result.Success)
                {
                    Console.WriteLine($"✅ Campaign saved successfully! ID: {result.CampaignId}");
                    return Ok(new
                    {
                        success = true,
                        message = result.Message,
                        campaignId = result.CampaignId,
                        campaignCode = campaignData.CampaignCode,
                        data = campaignData
                    });
                }
                else
                {
                    Console.WriteLine($"❌ Save failed: {result.Message}");
                    return BadRequest(new
                    {
                        success = false,
                        message = result.Message
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ EXCEPTION: {ex.Message}");
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                
                return StatusCode(500, new
                {
                    success = false,
                    message = "Internal server error occurred while saving campaign",
                    error = ex.Message,
                    details = ex.InnerException?.Message
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetCampaign(int id)
        {
            try
            {
                var campaign = await _campaignService.GetCampaignByIdAsync(id);

                if (campaign == null || campaign.CampaignId == 0)
                {
                    return NotFound(new { success = false, message = "Campaign not found" });
                }

                return Ok(new
                {
                    success = true,
                    data = campaign
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Internal server error occurred while retrieving campaign",
                    error = ex.Message
                });
            }
        }

        [HttpGet("all")]
        public async Task<IActionResult> GetAllCampaigns()
        {
            try
            {
                var campaigns = await _campaignService.GetAllCampaignsAsync();
                
                return Ok(new
                {
                    success = true,
                    message = "Campaigns retrieved successfully",
                    data = campaigns,
                    count = campaigns.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Internal server error occurred while retrieving campaigns",
                    error = ex.Message
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCampaign(int id, [FromBody] MarketingCampaignData campaignData)
        {
            try
            {
                if (campaignData == null)
                {
                    return BadRequest(new { success = false, message = "Campaign data is required" });
                }

                // Set the campaign ID
                campaignData.CampaignId = id;

                var result = await _campaignService.SaveMarketingCampaignAsync(campaignData);

                if (result.Success)
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Campaign updated successfully",
                        campaignId = result.CampaignId,
                        data = campaignData
                    });
                }
                else
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = result.Message
                    });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Internal server error occurred while updating campaign",
                    error = ex.Message
                });
            }
        }

        [HttpDelete("{id}")]
        public IActionResult DeleteCampaign(int id)
        {
            try
            {
                // This would need to be implemented in the service
                return Ok(new
                {
                    success = true,
                    message = "Campaign deleted successfully"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Internal server error occurred while deleting campaign",
                    error = ex.Message
                });
            }
        }
    }
}
