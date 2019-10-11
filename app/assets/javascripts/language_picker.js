const toggleLanguagePicker = () => {
  const languagePickerIcon = document.querySelector('.language-picker_icon');
  const languagePickerContent = document.querySelector('.language-picker_content');

  languagePickerIcon.classList.toggle('rotated');
  languagePickerContent.classList.toggle('is-visible');
}
