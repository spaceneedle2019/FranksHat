Typekit.load({async: true});
Scroller.speed = 40;

function randomizeHeaderImage() {
  var images =
    [
      '/images/ruhe_by_spaceneedle2019.jpg',
      '/images/sunset_at_lake_constance_by_spaceneedle2019.jpg',
      '/images/unchained_by_spaceneedle2019.jpg'
    ];

  var random = Math.floor(Math.random() * images.length);
  document.getElementById('header').style.backgroundImage = 'url(' + images[random] + ')';
}
