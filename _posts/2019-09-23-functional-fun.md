---
layout: post
title:  "A fun tidbit of functional programming"
---

-class MessageTransformer {
-  constructor(config) {
-    this.config = config;
-  }
-
-  transform(input) {
-    let output = '';
-    for (let product in this.config) {
-      if(this.config.hasOwnProperty(product)) {
-        output = input.replace(
-          RegExp(`\\b${product}\\b`, 'i'),
-          this.config[product]);
-        input = output;
-      }
-    }
-    return output;
-  }
}


function messageTransformer(replacements) {
  return Object.keys(replacements).map(str =>
    input => input.replace(
      RegExp(`\\b${str}\\b`, 'ig'),
      replacements[str])
  ).reduce((acc, f) => input => f(acc(input)), _ => _);
}
