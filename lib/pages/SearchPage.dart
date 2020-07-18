import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:samvada/models/user.dart';
import 'package:samvada/pages/HomePage.dart';
import 'package:samvada/widgets/ProgressWidget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

searchPageHeader(){


}



class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>
{

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>futureSearchResults;

  emptyTheTextFormField(){
  searchTextEditingController.clear();

  }

  controlSearching(String str){

    Future<QuerySnapshot>allUsers=usersReference.where("profileName",isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futureSearchResults=allUsers;
    });
  }
  AppBar  searchPageHeader(){

    return AppBar(
    backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.white),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "Search here...",
          hintStyle: TextStyle(color: Colors.grey),
           enabledBorder: UnderlineInputBorder(
             borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),

        ),
          filled: true,
          prefixIcon: Icon(Icons.person_pin,color: Colors.white,size: 30.0,),
            suffixIcon: IconButton(icon: Icon(Icons.clear,color: Colors.white,),onPressed: emptyTheTextFormField,)
        ),
        onFieldSubmitted: controlSearching,
      ),

    );


  }

 Container displayNoSearchResultsScreen(){
return Container(
  child: Center(
  child: ListView(
   shrinkWrap: true,
    children: <Widget>[
      Icon(Icons.group,color: Colors.grey,size: 200.0,),
      Text("Search Users",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white,fontWeight:FontWeight.w500,fontSize: 65.0 ),

      ),


      
    ],
  ),

  ),
);

  }

  displayUsersFoundScreen(){
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context,dataSnapShot){

        if(!dataSnapShot.hasData){
          return circularProgress();

        }

        List<UserResult> searchUsersResult=[];
        dataSnapShot.data.documents.forEach((docuemnt){
          User eachUser =User.fromDocument(docuemnt);
          UserResult userResult = UserResult(eachUser);
          searchUsersResult.add(userResult);
        });
        return ListView(children: searchUsersResult);
      },

    );


  }

  bool get wantKeepAlive=>true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black,
    appBar: searchPageHeader(),
      body: futureSearchResults==null ? displayNoSearchResultsScreen() : displayUsersFoundScreen(),

    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: <Widget>[
          GestureDetector(
            onTap: ()=>"Tapped",
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(eachUser.url),),
            title: Text(eachUser.profileName,style: TextStyle(
              color: Colors.black,fontSize: 16.0,fontWeight: FontWeight.bold,
            ),),
            subtitle: Text(eachUser.username,style: TextStyle(color: Colors.black,fontSize: 13.0),),
            ),
          )

          ],
        ),
      ),

    );
  }
}
