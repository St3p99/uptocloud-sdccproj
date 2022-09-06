// GENERAL
const bool DEBUG_MODE = false;
const String APPLICATION_TMP_DIRECTORY = "./tmp";

// AZURE DEPLOY
const bool HTTPS_ENABLED = true;
const String ADDRESS_AUTHENTICATION_SERVER = "uptocloud.azurewebsites.net";
const String ADDRESS_STORE_SERVER = "uptocloud.azurewebsites.net";

// LOCAL DEPLOY
// const bool HTTPS_ENABLED = false;
// const String ADDRESS_AUTHENTICATION_SERVER = "st3p99.ddnsfree.com";
// const String ADDRESS_STORE_SERVER = "st3p99.ddnsfree.com";


// DEBUG
// const bool HTTPS_ENABLED = false;
// const String ADDRESS_AUTHENTICATION_SERVER = "localhost:8081";
// const String ADDRESS_STORE_SERVER = "localhost:8180";


// AUTH
const String REALM = "UpToCloud-Realm";
const String CLIENT_ID = "uptocloud-microservice";
const String CLIENT_SECRET = "558235ab-035a-4886-b3fa-70156f637a6c";
const String REQUEST_LOGIN =
    "/auth/realms/" + REALM + "/protocol/openid-connect/token";

const String REQUEST_LOGOUT =
    "/auth/realms/" + REALM + "/protocol/openid-connect/logout";

// - SEARCH CONTROLLER
const String REQUEST_LOAD_RECENT_FILES = "/api/search/recent";
const String REQUEST_SEARCH_BY_TAGS = "/api/search/by-tags";
const String REQUEST_SEARCH_ANY_FIELDS_CONTAINS = "/api/search/any-fields-contains";
const String REQUEST_SEARCH_AUTOCOMPLETE = "/api/search/autocomplete";
const String REQUEST_SEARCH_TAG_SUGGESTIONS = "/api/search/tag-suggestions";
const String REQUEST_SEARCH_ANY_FIELDS_CONTAINS_AND_TAGS = "/api/search/any-fields-contains-and-tags";
const String REQUEST_LOAD_RECENT_FILES_READ_ONLY = "/api/search/recent-read-only";
const int DEFAULT_PAGE_SIZE = 5;

// - USER CONTROLLER
const String REQUEST_DELETE = "api/users/delete";
const String REQUEST_ADD_USER = "api/users/new";
const String REQUEST_LOAD_USER = "/api/users";
const String REQUEST_SEARCH_USER_BY_EMAIL = "/api/users/byEmail";
const String REQUEST_SEARCH_USER_BY_EMAIL_CONTAINS = "/api/users/byEmail-contains";
const String REQUEST_NEW_USER = "/api/users/new";

// FILE CONTROLLER
const String REQUEST_SET_METADATA = "/api/files/set_metadata";
const String REQUEST_ADD_READERS = "/api/files/add-readers";
const String REQUEST_REMOVE_READERS = "/api/files/remove-readers";
const String REQUEST_SHARE_SUGGESTIONS = "/api/files/share-suggestions";
const String REQUEST_GET_READERS_BY_DOC = "/api/files/readersByDoc";
const String REQUEST_UPLOAD_FILES = "api/files/upload-multiple";
const String REQUEST_UPLOAD_FILE = "api/files/upload";
const String REQUEST_DOWNLOAD_FILE = "api/files/download";
const String REQUEST_DOWNLOAD_FILE_STREAM = "api/files/download-stream";
const String REQUEST_DELETE_FILE = "api/files/delete";


// ERROR MESSAGE
const String ERROR_RESERVATION_ALREADY_EXIST =
    "ERROR_RESERVATION_ALREADY_EXIST";
const String ERROR_SEATS_UNAVAILABLE = "ERROR_SEATS_UNAVAILABLE";
const String ERROR_REVIEW_ALREADY_EXISTS = "ERROR_REVIEW_ALREADY_EXISTS";

// ROLES

// STORAGE
const String STORAGE_REFRESH_TOKEN = "refresh_token";
const String STORAGE_EMAIL = "email";

// responses
const String RESPONSE_ERROR_MAIL_USER_ALREADY_EXISTS =
    "ERROR_MAIL_USER_ALREADY_EXISTS";

const String RESPONSE_ERROR_USERNAME_ALREADY_EXISTS =
    "ERROR_USERNAME_ALREADY_EXISTS";
// messages
const String MESSAGE_CONNECTION_ERROR = "connection_error";

const Map<String, String> FILE_TYPE_ICONS_MAP = {
  "text": "txt.png",
  "image": "image.png",
  "video": "video.png",
  "audio": "mp3.png",
  "application/pdf": "pdf.png",

  "application/msword": "doc.png",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
      "doc.png",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.template":
      "doc.png",
  "application/vnd.ms-word.document.macroEnabled.12": "doc.png",
  "application/vnd.ms-word.template.macroEnabled.12": "doc.png",

  "application/vnd.ms-excel": "xls.png",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
      "xls.png",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.template":
      "xls.png",
  "application/vnd.ms-excel.sheet.macroEnabled.12": "xls.png",
  "application/vnd.ms-excel.template.macroEnabled.12": "xls.png",
  "application/vnd.ms-excel.addin.macroEnabled.12": "xls.png",
  "application/vnd.ms-excel.sheet.binary.macroEnabled.12": "xls.png",

  "application/vnd.ms-powerpoint": "ppt.png",
  "application/vnd.openxmlformats-officedocument.presentationml.presentation":
      "ppt.png",
  "application/vnd.openxmlformats-officedocument.presentationml.template":
      "ppt.png",
  "application/vnd.openxmlformats-officedocument.presentationml.slideshow":
      "ppt.png",
  "application/vnd.ms-powerpoint.addin.macroEnabled.12": "ppt.png",
  "application/vnd.ms-powerpoint.presentation.macroEnabled.12": "ppt.png",
  "application/vnd.ms-powerpoint.template.macroEnabled.12": "ppt.png",
  "application/vnd.ms-powerpoint.slideshow.macroEnabled.12": "ppt.png",
  "application/vnd.ms-access": "ppt.png"
};
