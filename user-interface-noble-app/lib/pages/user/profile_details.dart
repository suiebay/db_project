class ProfileDetails {
  String userId = '';
  String firstName = '';
  String lastName = '';
  String middleName = '';
  String phone = '';
  String email = '';
  String recommendationBook = '';
  int readsPoint;
  String avatar = '';
  int finishedBooksNum;
  int readsReviewNumber;
  int gender;

  ProfileDetails({ this.userId, this.firstName, this.lastName, this.middleName , this.phone, this.email,
    this.recommendationBook, this.avatar, this.readsPoint, this.finishedBooksNum, this.readsReviewNumber, this.gender });

  String getUserId() { return userId; }

  String getFirstName() { return firstName; }

  String getLastName() { return lastName; }

  String getMiddleName() { return middleName; }

  String getAvatar() { return avatar; }

  int getGender() {return gender; }

  String getPhone() { return phone; }

  String getEmail() { return email; }

  String getRecommendationBook() { return recommendationBook; }

  int getReadsPoint() { return readsPoint; }

  int getFinishedBooksNum() { return finishedBooksNum; }

  int getReadsReviewNumber() { return readsReviewNumber; }

  ProfileDetails.fromJson(Map<String, dynamic> json)
      : userId = json["id"],
        firstName = json['firstName'] != '' ? json["firstName"] : '',
        lastName = json['lastName'] != '' ? ' ${json["lastName"]}' : '',
        middleName = json["middleName"] != null ? ' ${json["middleName"]}' : '',
        phone = json["phone"] != null ? json["phone"] : '',
        email = json["email"] != null ? json["email"] : '',
        recommendationBook = json["readsRecommendation"],
        avatar = json["avatar"],
        readsPoint = json["readsPoint"],
        finishedBooksNum = json["readsFinishedBooks"],
        readsReviewNumber = json["readsReviewNumber"],
        gender = json["gender"];
}