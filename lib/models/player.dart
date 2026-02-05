class Player {
  final String name;
  final String avatarUrl;

  Player({required this.name})
      : avatarUrl = "https://minotar.net/helm/$name/100.png";
}
