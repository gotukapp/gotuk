class Review {
  final String name;
  final String img;
  final String message;
  final double score;

  Review(this.name, this.img, this.message, this.score);

  Review.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        img = json['img'] as String,
        message = json['message'] as String,
        score = json['score'] as double;

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'img': img,
        'message': message,
        'score': score
      };
}
