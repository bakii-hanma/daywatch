class CommentModel {
  final String id;
  final String userName;
  final String timeAgo;
  final String comment;
  final String avatarPath;

  const CommentModel({
    required this.id,
    required this.userName,
    required this.timeAgo,
    required this.comment,
    required this.avatarPath,
  });
}
