class MyFunctions {
  bool checkIsEmailValid(String email) {
    final regex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(regex).hasMatch(email);
  }
}
