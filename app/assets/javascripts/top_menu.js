const toggleMenu = (item) => {
  item.classList.toggle("change");

  const menu = document.getElementById("navigation");
  if (menu.className === "navigation") {
    menu.className += " responsive";
  } else {
    menu.className = "navigation";
  }
}

const toggleDropdown = () => {
  const dropdownContent = document.querySelector('.dropdown__content');

  dropdownContent.classList.toggle('is-visible');
}
