var stripe = Stripe("pk_test_51Jf4GEFFrya4Rc8JUuxAqZKFlYiUvsB9UYkbVYNdzuwP6SFKBMTtUOzBO5QttZBlmazVCyU6MRTkdJQjTdLdZ0sg00usxEQbZq");


fetch("/create-payment-intent", {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify(purchase)
})

 var elements = stripe.elements();