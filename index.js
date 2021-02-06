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

    getData(user);
})


const db = firebase.firestore();

function getData(user) {
  if(!user) return;

  // db.collection(collection(user)).get().then(query => {
  //   const items = [];
  //   const now = today();
  //   query.forEach(item => {
  //     const data = item.data();
  //     const lw = dayjs(data.lastWashed);
  //     const dueOn = lw.add(data.intervalInDays, 'day');
  //     const dueInDays = dueOn.diff(now, 'day');
  //     items.push({
  //       id: item.id,
  //       ...item.data(),
  //       dueInDays, 
  //     })
  //   })
  //   if (elm) {
  //     elm.ports.receivedItems.send(items);
  //   }
  // })
}

// function collection({uid}) {
//   return `${uid}_items`;
// }