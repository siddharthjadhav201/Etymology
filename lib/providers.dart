import "dart:developer";

import "package:provider/provider.dart";
import "package:flutter/material.dart";

class MainProvider extends ChangeNotifier{
    int strLength=0;
    void changeLength( int newStrLength){
      strLength=newStrLength;
      // log("$newStrLength");
      notifyListeners();
      
    }
}