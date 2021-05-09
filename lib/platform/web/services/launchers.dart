import 'package:url_launcher/url_launcher.dart';

final String _url = 'https://github.com/yahu1031/passman';

GitLaunch gitLaunch = GitLaunch();

class GitLaunch {
  Future<void> openGitLink() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
}
