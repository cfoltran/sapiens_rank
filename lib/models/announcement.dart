import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.body,
    this.link,
    this.linkLabel,
  });

  final String id;
  final String body;

  /// Optional target — an external URL (http/https) or an in-app deeplink
  /// (e.g. challenge://, map://, today://).
  final String? link;

  /// Optional call-to-action label shown next to the arrow.
  final String? linkLabel;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] as String,
    body: json['body'] as String,
    link: json['link'] as String?,
    linkLabel: json['link_label'] as String?,
  );

  @override
  List<Object?> get props => [id, body, link, linkLabel];
}
