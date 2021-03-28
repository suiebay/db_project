class Moderator {
  String name;
  String surname;
  String description;
  int image;
  int color;

  Moderator({ this.name, this.description, this.image, this.color, this.surname }) ;

  int getImage() { return image; }

  String getSurname() { return surname; }

  String getName() { return name; }

  String getDescription() { return description; }

  int getColor() { return color; }

}