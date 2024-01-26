class MyFunctions {
  bool checkIsEmailValid(String email) {
    const regex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(regex).hasMatch(email);
  }
}
