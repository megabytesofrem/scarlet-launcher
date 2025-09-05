// Helper functions for converting game names and extracting localization info

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
  const gameNames = {
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

  const friendlyName = gameNames[gameId] || originalName;

  // Find the localization based on the suffix, falls back to Japanese
  // th06 (en).exe -> English
  // th06 (fr).exe -> French
  // th06.exe      -> Japanese

  localization = extractLocalization(originalName);
  return friendlyName;
}
