<?php
if (1 == $_REQUEST['success'] || 1 == $_REQUEST['cancel']) {
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <title>Payment Redirect Page</title>
  <meta name="description" content="A demo of Stripe Payment Intents" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- Load Stripe.js on your website. -->
  <script src="https://js.stripe.com/v3/"></script>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
</head>

<body>
  <div id="error-message">Preparing payment...</div>
  <script>
    var PUBLISHABLE_KEY = "<?=$_REQUEST['pk']?>";
    var DOMAIN = window.location.origin;
    var SKU_ID = "<?=$_REQUEST['sku']?>";
    var stripe = Stripe(PUBLISHABLE_KEY);

    // Handle any errors from Checkout
    function handleResult(result) {
      if (result.error) {
        var displayError = document.getElementById("error-message");
        displayError.textContent = result.error.message;
      }
    };

    function buy() {
      // Make the call to Stripe.js to redirect to the checkout page
      // with the current quantity
      stripe
        .redirectToCheckout({
          items: [{
            sku: SKU_ID,
            quantity: 1
          }],
          successUrl: DOMAIN + "/stripe.php?success=1&session_id={CHECKOUT_SESSION_ID}",
          cancelUrl: DOMAIN + "/stripe.php?cancel=1"
        })
        .then(handleResult);
    }

    setTimeout(() => {  buy(); }, 500);
  </script>
</body>

</html>
