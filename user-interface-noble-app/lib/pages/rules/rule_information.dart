class RuleInformation {
  String ruleId;
  String title;
  String description;

  RuleInformation({ this.ruleId, this.description, this.title }) ;

  String getRuleId() { return ruleId; }

  String getTitle() { return title; }

  String getDescription() { return description; }

  factory RuleInformation.fromJson(Map<String, dynamic> json) {
    return RuleInformation(
      ruleId: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}