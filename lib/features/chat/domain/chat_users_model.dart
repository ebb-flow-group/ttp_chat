class ChatUsersModel
{
  String? avatar, fullName, userName, lastMessage;
  int? lastMessageTimeStamp, unreadMessagesCount;

  ChatUsersModel(this.avatar, this.fullName, this.userName, this.lastMessage,
      this.lastMessageTimeStamp, this.unreadMessagesCount);
}