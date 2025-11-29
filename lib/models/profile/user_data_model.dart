class UserDataModel {
  Profile? profile;

  UserDataModel({this.profile});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? id;
  String? userName;
  String? email;
  String? phone;
  String? address;
  String? userPhoto;

  Profile(
      {this.id,
        this.userName,
        this.email,
        this.phone,
        this.address,
        this.userPhoto});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    userPhoto = json['user_photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_name'] = this.userName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['user_photo'] = this.userPhoto;
    return data;
  }
}
