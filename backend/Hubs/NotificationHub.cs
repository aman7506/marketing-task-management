using Microsoft.AspNetCore.SignalR;

namespace MarketingTaskAPI.Hubs
{
    public class NotificationHub : Hub
    {
        public async Task SendMessage(string user, string message)
        {
            await Clients.All.SendAsync("ReceiveMessage", user, message);
        }

        public async Task SendTaskNotification(string action, int taskId, string taskDescription)
        {
            await Clients.All.SendAsync("TaskNotification", action, taskId, taskDescription);
        }
        
        public async Task SendTaskAssignedNotification(int taskId, string employeeName, string taskDescription)
        {
            await Clients.All.SendAsync("TaskAssigned", taskId, employeeName, taskDescription);
        }

        public override async Task OnConnectedAsync()
        {
            await base.OnConnectedAsync();
            await Clients.All.SendAsync("UserConnected", Context.ConnectionId);
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await base.OnDisconnectedAsync(exception);
            await Clients.All.SendAsync("UserDisconnected", Context.ConnectionId);
        }
    }
}