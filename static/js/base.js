Typekit.load({ async: true });
Scroller.speed = 40;

const currentDate = new Date();

function randomizeHeaderImage() {
  const images = [
    "images/ruhe_by_spaceneedle2019.jpg",
    "images/sunset_at_lake_constance_by_spaceneedle2019.jpg",
    "images/unchained_by_spaceneedle2019.jpg",
    "images/sands_by_spaceneedle2019.jpg",
    "images/sunset_malmo_by_spaceneedle2019.jpg",
  ];

  const random = Math.floor(Math.random() * images.length);
  document.getElementById("header").style.backgroundImage =
    "url(" + images[random] + ")";
}

function setCopyrightYear() {
  const copyrightYear = document.getElementById("copyright-year");
  copyrightYear.textContent = currentDate.getFullYear().toString();
}

function setCurrentDate() {
  const firstDate = document.getElementsByClassName("date")[0];
  firstDate.textContent = currentDate.toLocaleString("de-DE");
}
