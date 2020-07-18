import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:samvada/pages/CreateAccountPage.dart';
import 'package:samvada/pages/NotificationsPage.dart';
import 'package:samvada/pages/ProfilePage.dart';
import 'package:samvada/pages/SearchPage.dart';
import 'package:samvada/pages/TimeLinePage.dart';
import 'package:samvada/pages/UploadPage.dart';
import 'package:samvada/models/User.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Picture");
final postReference = Firestore.instance.collection("posts");
final DateTime timesnap = DateTime.now();
User currentUser;

class _HomePageState extends State<HomePage> {

  bool  isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  void initState(){
    super.initState();
    pageController =PageController();


    gSignIn.onCurrentUserChanged.listen((gSigninAccount) {
      controlSignIn(gSigninAccount);

    },onError:(gError) {
      print("Error Message:"+gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
      controlSignIn(gSignInAccount);
    }).catchError((gError){
      print("Error Message:"+gError);

    });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async{

    if(signInAccount!=null){

      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn=true;

      });

    } else{
      setState(() {
        isSignedIn=false;
      });

    }

  }

  saveUserInfoToFireStore() async{
  final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
  DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();

  if(!documentSnapshot.exists){
 final username =await Navigator.push(context,MaterialPageRoute(builder:(context)=> CreateAccountPage()));

  usersReference.document(gCurrentUser.id).setData({
    "id":gCurrentUser.id,
    "profileName":gCurrentUser.displayName,
    "username":username,
    "url":gCurrentUser.photoUrl,
    "email":gCurrentUser.email,
    "bio":"",
    "timestamp":timesnap,
 });
documentSnapshot= await usersReference.document(gCurrentUser.id).get();

  }
currentUser = User.fromDocument(documentSnapshot);
  }

  void dispose(){
   pageController.dispose();
   super.dispose();

  }

  loginUser(){

    gSignIn.signIn();

  }
  logoutUser(){
    gSignIn.signOut();

  }

  whenPageChanges(int pageIndex){

    setState(() {
      this.getPageIndex=pageIndex;

    });

  }

  OnTapChangePage(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }


  Widget buildHomeScreen(){
    return Scaffold(
    body:PageView (
    children: <Widget>[
     TimeLinePage(),
     //RaisedButton.icon(onPressed: logoutUser, icon:Icon(Icons.close), label: Text("Sign Out")),
     SearchPage(),
      UploadPage(gCurrentUser: currentUser,),
      NotificationsPage(),
      ProfilePage(),
    ],
      controller: pageController,
      onPageChanged: whenPageChanges,
      physics: NeverScrollableScrollPhysics(),
    ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: OnTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size:37.0)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person))
        ],

    ),

    );


    //return RaisedButton.icon(onPressed: logoutUser, icon:Icon(Icons.close), label: Text("Sign Out"));
  }

  Scaffold buildSignInScreen(){

    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Samvad",
              style: TextStyle(fontSize: 92.0,color: Colors.white,fontFamily: "Signatra"),

            ),

            GestureDetector(
              onTap:loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/google_signin_button.png"),
                      fit: BoxFit.cover,

                    )

                ),
              ),

            )


          ],


        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    if(isSignedIn){
      return buildHomeScreen();

    } else {


      return buildSignInScreen();

    }

  }
}
