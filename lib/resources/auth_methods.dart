import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/utils.dart';


class AuthMethods{
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async{
    User currentUser =_auth.currentUser!;
    DocumentSnapshot snap=await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);

  }


  /// Signup User function
  Future<String> signUpUser({required String email, required String password, required String username, required String bio, required Uint8List file,}) async {
    String res='Some error occurred';

    try{

      if(email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || bio.isNotEmpty || file!=null){
        ///  resister user
        UserCredential credential=await _auth.createUserWithEmailAndPassword(email: email, password: password);
        // print("user id --------${credential.user!.uid}");

        String photoUrl = await StorageMethods().uploadImageToStorage("profilePic", file, false);
        // add user to database
        // print("photoUrl id --------$photoUrl");

        model.User user=model.User(
          username: username,
          uid: credential.user!.uid,
          email: email,
          bio: bio,
          photoUrl: photoUrl,
          followers: [],
          following: [],

        );

        await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());
        res='success';
      }

    }on FirebaseAuthException catch (err){
      if(err.code=='invalid-email'){
        res = 'The Email is Not in Right format';
      }
      if(err.code=='weak-password'){
        res='Password should be at least 6 Character';
      }
    }
    catch(err){
      res=err.toString();
    }
    if(username.isEmpty){
      res='Name can not be empty';
    }
    if(email.isEmpty){
      res='email can not be empty';
    }
    if(password.isEmpty){
      res='password can not be empty';
    }
    if(bio.isEmpty){
      res='bio can not be empty';
    }
    return res;
  }


  /// logging in user function
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    }
    catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}