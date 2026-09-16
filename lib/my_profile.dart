class MyProfile {
  String date;
  String workOfPlace;
  String jobTitle;

  MyProfile({
    this.date = '24/12/2024',
    this.workOfPlace = 'Đại học Phenikaa',
    this.jobTitle = 'Giảng viên',
  });

  void setMyProfile(String date, String workOfPlace, String jobTitle) {
    this.date = date;
    this.workOfPlace = workOfPlace;
    this.jobTitle = jobTitle;
  }

  String getMyProfile() {
    return workOfPlace;
  }

  String getProfileSummary() {
    return '$jobTitle tại $workOfPlace ($date)';
  }
}
