// Helper functions for converting game names and extracting localization info

var notTouhou = false;
var localization = "jp"; // Default to Japanese

// Mapping of Touhou game IDs to their friendly names
const GAME_NAMES = {
  th06: "Touhou 6: Embodiment of Scarlet Devil",
  th07: "Touhou 7: Perfect Cherry Blossom",
  th08: "Touhou 8: Imperishable Night",
  th09: "Touhou 9: Phantasmagoria of Flower View",
  th10: "Touhou 10: Mountain of Faith",
  th11: "Touhou 11: Subterranean Animism",
  th12: "Touhou 12: Undefined Fantastic Object",
  th13: "Touhou 13: Ten Desires",
  th14: "Touhou 14: Double Dealing Character",
  th15: "Touhou 15: Legacy of Lunatic Kingdom",
  th16: "Touhou 16: Hidden Star in Four Seasons",
  th17: "Touhou 17: Wily Beast and Weakest Creature",
  th18: "Touhou 18: Unconnected Marketeers",
  th19: "Touhou 19: Unfinished Dream of All Living Ghost",
  th20: "Touhou 20: Fossilized Wonders",
};

function convertFriendlyName(name) {
  if (!name) return "Unknown Game";

  // Extract th## pattern from anywhere in the string
  let match = name.match(/th(\d{2})/i);
  if (match) {
    let gameId = "th" + match[1];
    notTouhou = false;
    return getTouhouName(gameId, name);
  } else {
    // Not a touhou game, mark it as such
    notTouhou = true;
  }

  return name;
}

function extractLocalization(name) {
  let match = name.match(/th(\d{2})\s*\((\w{2})\)/);
  if (match && match[2]) {
    // We need to do a second step, and map en to us
    return match[2] === "en" ? "us" : match[2];
  }

  // If no match, check if it's just th## with no localization (assume jp)
  match = name.match(/th\d{2}\s*$/);
  if (match) {
    return "jp";
  }

  // Fallback to Japanese localization
  return "jp";
}

function getTouhouName(gameId, originalName) {
  // Map game versions to their friendly names
  const friendlyName = GAME_NAMES[gameId] || originalName;

  // Find the localization based on the suffix, falls back to Japanese
  // th06 (en).exe -> English
  // th06 (fr).exe -> French
  // th06.exe      -> Japanese

  localization = extractLocalization(originalName);
  return friendlyName;
}

// Grid helpers
function getAuthHeader() {
  // Access the authorization token from QML context
  if (typeof sgdAuthKey !== "string" || sgdAuthKey.length === 0) {
    console.error("SteamGridDB authorization token is not set.");
    return "";
  }

  return "Bearer " + sgdAuthKey;
}

function buildQueryParams(params) {
  return Object.keys(params)
    .map(
      (key) => encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
    )
    .join("&");
}

function request(url, key, callback, error) {
  let xhr = new XMLHttpRequest();
  xhr.open("GET", url);
  xhr.setRequestHeader("Authorization", getAuthHeader());
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        let response = JSON.parse(xhr.responseText);
        if (response && response[key]) {
          callback(response[key]);
        } else {
          console.error("Invalid response from SteamGridDB:", xhr.responseText);
          error("Invalid response from SteamGridDB");
        }
      } else {
        console.error(
          "Error fetching from SteamGridDB:",
          xhr.status,
          xhr.statusText
        );
        error("Error fetching from SteamGridDB: " + xhr.statusText);
      }
    }
  };
  xhr.send();
}

function searchGame(query, callback) {
  if (!query || query.length < 3) {
    console.warn("Query too short for SteamGridDB search");
    callback([]);
    return;
  }

  let url =
    "https://www.steamgriddb.com/api/v2/search/autocomplete/" +
    encodeURIComponent(query);

  request(url, "data", callback, function (err) {
    console.error("Search error:", err);
    callback([]);
  });
}

function fetchGrids(appId, callback) {
  if (!appId) {
    console.warn("App ID is required to fetch grids");
    callback([]);
    return;
  }

  let params = {
    dimensions: "600x900",
    styles: "alternate",
    mimes: "image/png,image/jpeg", // fuck webp
  };

  let url =
    "https://www.steamgriddb.com/api/v2/grids/game/" +
    encodeURIComponent(appId) +
    "?" +
    buildQueryParams(params);

  request(url, "data", callback, function (err) {
    console.error("Fetch grids error:", err);
    callback([]);
  });
}

function findClosestMatch(grids, exactName) {
  if (!grids || grids.length === 0) return null;

  // First, try exact match
  for (let grid of grids) {
    if (grid.name.toLowerCase() === exactName.toLowerCase()) {
      return grid;
    }
  }

  // If no exact match, try partial match for the specific game's version
  let version = exactName.split(":")[0].trim();
  for (let grid of grids) {
    if (grid.name.toLowerCase().includes(version.toLowerCase())) {
      return grid;
    }
  }

  // No match found
  return null;
}

function extractGridImage(gameName, callback) {
  let imageUrl = null;
  if (notTouhou) {
    console.error("Not a Touhou game, cannot fetch grid image");
    callback(null);
    return;
  }

  console.log("Searching SteamGridDB for", gameName);

  searchGame(gameName, function (results) {
    if (results.length === 0) {
      console.warn("No search results from SteamGridDB for", gameName);
      callback(null);
      return;
    }

    // Find the best match from the search results
    let matches = findClosestMatch(results, gameName);
    if (!matches) {
      console.warn("No matching game found on SteamGridDB for", gameName);
      callback(null);
      return;
    }

    // Fetch the grids for the matched game ID
    fetchGrids(matches.id, function (grids) {
      if (grids.length === 0) {
        console.warn("No grids found for game ID", matches.id);
        callback(null);
        return;
      }

      // Return the first grid
      imageUrl = grids[0].url;
      console.log("Found grid image URL:", imageUrl);
      callback(imageUrl);
    });
  });
}
