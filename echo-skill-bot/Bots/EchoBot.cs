// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Bot.Builder;
using Microsoft.Bot.Schema;

namespace Microsoft.BotBuilderSamples.EchoSkillBot.Bots
{
    public class EchoBot : ActivityHandler
    {
        protected override async Task OnMessageActivityAsync(ITurnContext<IMessageActivity> turnContext, CancellationToken cancellationToken)
        {
            if (turnContext.Activity.Text.Contains("end") || turnContext.Activity.Text.Contains("stop"))
            {
                // Send End of conversation at the end.
                var messageText = $"Ending conversation from the skill...";
                await turnContext.SendActivityAsync(MessageFactory.Text(messageText, messageText, InputHints.IgnoringInput), cancellationToken);
                var endOfConversation = Activity.CreateEndOfConversationActivity();
                endOfConversation.Code = EndOfConversationCodes.CompletedSuccessfully;
                await turnContext.SendActivityAsync(endOfConversation, cancellationToken);
            }
            else
            {
                var messageText = string.Join("\r\n",
                    FormatMessageActivity(turnContext.Activity),
                    FormatActivity(turnContext.Activity),
                    FormatConversation(turnContext.Activity.Conversation),
                    FormatTurnContext(turnContext));

                await turnContext.SendActivityAsync(MessageFactory.Text(messageText, messageText, InputHints.IgnoringInput), cancellationToken);
                messageText = "Say \"end\" or \"stop\" and I'll end the conversation and back to the parent.";
                await turnContext.SendActivityAsync(MessageFactory.Text(messageText, messageText, InputHints.ExpectingInput), cancellationToken);
            }
        }

        protected override Task OnEndOfConversationActivityAsync(ITurnContext<IEndOfConversationActivity> turnContext, CancellationToken cancellationToken)
        {
            // This will be called if the root bot is ending the conversation.  Sending additional messages should be
            // avoided as the conversation may have been deleted.
            // Perform cleanup of resources if needed.
            return Task.CompletedTask;
        }

        private string FormatTurnContext(ITurnContext context)
        {
            var turnState = string.Join(
                ", ", 
                context.TurnState.AsEnumerable().Select(item => $"[{item.Key}-{item.Value}]").ToArray()).
                Replace("\r\n", string.Empty);
            
            return $"---------- Turn context ----------\r\nState - {turnState}\r\nResponded - {context.Responded}\r\n";
        }
        private string FormatMessageActivity(IMessageActivity activity)
        {
            return $"---------- Message ----------\r\nFrom - {activity.From.Name}\r\nMessage - {activity.Text}\r\nLocale - {activity.Locale}\r\nSpeak - {activity.Speak}\r\nInputHint - {activity.InputHint}\r\nSummary - {activity.Summary}";
        }

        private string FormatActivity(IActivity activity)
        {
            return $"---------- Activity ----------\r\nType - {activity.Type}\r\nId - {activity.Id}\r\nTimestamp - {activity.Timestamp}\r\nLocalTimestamp - {activity.LocalTimestamp}\r\nServiceUrl - {activity.ServiceUrl}\r\nChannelId - {activity.ChannelId}\r\nRecipient - {activity.Recipient.Name}\r\nFrom - {activity.From.Name}";
        }

        private string FormatConversation(ConversationAccount conversation)
        {
            return $"---------- Conversation ----------\r\nIsGroup - {conversation.IsGroup}\r\nConversationType - {conversation.ConversationType}\r\nId - {conversation.Id}\r\nName - {conversation.Name}\r\nAadObjectId - {conversation.AadObjectId}\r\nRole - {conversation.Role}\r\nTenantId - {conversation.TenantId}";
        }
    }
}
