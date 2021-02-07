import { Elm } from "./src/Main.elm";

import * as firebase from "firebase/app";

import "firebase/auth";
import "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAMGfJmtSyqY16dnUW2E7abjuaGYmgJyRw",
  authDomain: "doglogger-7554d.firebaseapp.com",
  projectId: "doglogger-7554d",
  storageBucket: "doglogger-7554d.appspot.com",
  messagingSenderId: "62116958650",
  appId: "1:62116958650:web:cdb36314e3891345f20d83"
};

firebase.initializeApp(firebaseConfig);

let elm; 
firebase.auth().onAuthStateChanged((user) => {
    elm = Elm.Main.init({
      node: document.getElementById('root'),
      flags: { user: user },
      replace: false,
    });

    elm.ports.signIn.subscribe(([username, password]) => {
      firebase.auth().signInWithEmailAndPassword(username, password).catch(err => { 
        elm.ports.signInError.send(err.message);
      });
    });

    elm.ports.signOut.subscribe(() => {
      firebase.auth().signOut();
    });

    elm.ports.pooNow.subscribe(() => {
      db.collection('poos').add({ timestamp: +new Date()}).then(() => {
        elm.ports.complete.send('complete');
      })
    });

    elm.ports.pooThen.subscribe((timestamp) => {
      db.collection('poos').add({ timestamp}).then(() => {
        elm.ports.complete.send('complete');
      })
    });

    elm.ports.whoopsNow.subscribe(() => {
      db.collection('whoops').add({ timestamp: +new Date()}).then(() => {
        elm.ports.complete.send('complete');
      })
    });

    elm.ports.whoopsThen.subscribe((timestamp) => {
      db.collection('whoops').add({ timestamp}).then(() => {
        elm.ports.complete.send('complete');
      })
    });

    getData(user);
})


const db = firebase.firestore();

function getData(user) {
  if(!user) return;

  db.collection('poos').get().then(query => {
    const items = [];
    query.forEach(item => {
      const data = item.data();
      console.log(data)
    })
    // if (elm) {
    //   elm.ports.receivedItems.send(items);
    // }
  })
}