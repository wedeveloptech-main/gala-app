class UnboardingContent {
  String image;
  String title;
  String description;

  UnboardingContent({required this.image, required this.title, required this.description});
}

List<UnboardingContent> contents = [
  UnboardingContent(
      title: 'Gala Caterers',
      image: 'assets/images/Board 1.png',
      description: "One stop solution for all your \ncatering needs.."
  ),
  UnboardingContent(
      title: 'Spice Up Your Occasions',
      image: 'assets/images/Board 2.png',
      description: "Be it a large, mid or small sized event, we cover it all.."
  ),
  UnboardingContent(
      title: 'We Cater To Corporates Too!',
      image: 'assets/images/Board 3.png',
      description: "We provide end-to-end corporate \ncatering services."
  ),
];