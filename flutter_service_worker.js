'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "5ae1bef820591bdba8281cd353435191",
"version.json": "f21b77009aa3d2bf8e49b390d379b8a2",
"index.html": "6f473cc8f2507c7222f9d4d7cba72644",
"/": "6f473cc8f2507c7222f9d4d7cba72644",
"main.dart.js": "6d366bb453330a7813ac2eade5ac99ac",
"flutter.js": "f31737fb005cd3a3c6bd9355efd33061",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "a0bea58ca81645b22c8be06973991b3e",
".git/config": "e9bb92503d0a9aace140e0270c3fca1c",
".git/objects/58/823647fc7e42971f2579aae84594c63cd1f2ff": "7021c5def8691899dc3a83ac6f25d091",
".git/objects/a4/a958b01bfcda181258ee8bf755970edc564a67": "0baa76fb7f9527e7f4933d249b2535ef",
".git/objects/a4/6cf0184a3354225fcd713a800544d7384ae4ba": "d97e4b1d34375d3ab6f028ce4315f4b9",
".git/objects/df/90f348b1df693c322fc1cecbc63dab057f99fd": "750541b68c15a01db82417414a8d76b9",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d6/26b3d389eddbe44191e8264d86fdd69c6c4261": "ac0e9a978df09fa717ca308c03aa9403",
".git/objects/d8/69c3bd746253fd17b199f6d695ab7378b9c22e": "b6018dc6d2a94e898415d518b01d2994",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/b2da9a9b5495a8ebe4f1929740cdedd07ebaf3": "fef7cbebe11df8141e7695dfd4278621",
".git/objects/f5/010cda95492006dae3638dfb01a8d0822a1e6a": "04eb9fcdf209b67f396e5ab84cb956e2",
".git/objects/20/25704c8147db3e353cd01b35db62f623a4212a": "2ba15400e252d5b3dc483fc079d2ad50",
".git/objects/20/1afe538261bd7f9a38bed0524669398070d046": "82a4d6c731c1d8cdc48bce3ab3c11172",
".git/objects/16/5da67191b73406e15fc3e6cf7cda3c195dc735": "86cfac30d97fb45bba2f4417782645d6",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/2f/343f8476ced48b8bf1e149c783d51ded7706d5": "f949caf17e83eb6cba24d08001bc2e36",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/00/257cba2ca2374553eeff6254a70cc6ed2eb027": "3bc8ebe0badcfac270c586d2117432f0",
".git/objects/09/831a865be68fc527581491cf79ba93191376f9": "e607221112e83302a3a16ee638137e87",
".git/objects/5d/15fadf1864d70c7184fca7d3efde79cdf68af5": "79a44d8578cc18e3add64aa6a97f0da0",
".git/objects/31/0ee6c0cf43719931ae3470b06d1b044026b6ff": "e3fad2d75b56d517b58ae97ae684aeb7",
".git/objects/53/d13f33d595b8ed8472c982e66a8e493298f23c": "a497f0798fe4c40945b263a8c341e8f2",
".git/objects/30/5ddd3ab5ec3ab9bc3e7683ff19be1ae88b098e": "84d4c75e23c7ce60f3ccb1ef82d6484b",
".git/objects/5e/7724d4d493d51a7d3bcca3b2cc092157d60cef": "c0069579f1e9d7857bbb384d767f5508",
".git/objects/37/a919675ed15dbc3f9fbaed9cd663bb4e54a47b": "85b9de44922bd415f81ac0ed32203d4f",
".git/objects/6d/f28bc6b2a034d2cf9691299e84aaceaf564e01": "dcb1f5d5dd87bf1fbd62b1eafa878499",
".git/objects/01/a2db92c9822874d3574e47e2b108c620776d9d": "1a440a957c4cdc361315b5b7fef1f9ee",
".git/objects/6c/0d0e4d280f385ad71bd575394235fece9dd948": "7cb6a49f5601db7f464e516860991ed0",
".git/objects/99/b9c0e5f47686f54c3e8d265d452350a569c0da": "bb83410af140d91e31edb5d9d87d9d61",
".git/objects/0a/38046ff8a596a9c2d3b305176d8481cbb00b2b": "bb28169968b11d7a71236a65230f63e0",
".git/objects/d3/68264a2f263cc216f85008dc3632c2ed7d0838": "204178e6040db8b89c7ed632eb14bd9a",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b0/67c2ba94b46e8b99660a55f34c52039f4c65f2": "cf7fcab02c05142cda68cebd958e7e6a",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/ef/70fcc24c56c04404296c6b6af5b93e61f859dc": "414841f13907c30d5188c8e589026cc5",
".git/objects/c4/a06cd0e45957b48f7b63b5bbccc224569a5ada": "26d20eaea4c6c0abbf21f876063e5c86",
".git/objects/cc/39abc5e810fc5b54efa2bbc59ed1b45c01bf8d": "e976c2b73e19e077b9abe8e304b2c229",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/79/5b150ff88f7a9a24ccb2d2623b349016feb39e": "4a857680c243274bb04994a2e3455a45",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/71/afb1d4cf2a9c922c72c9cc05861f4056827965": "25588449869979b20fd6740cd40cb138",
".git/objects/82/00915ab49c0f95c63e66a1c214650e17639ab2": "a46e5636af100ef81eb00ea6bf559b71",
".git/objects/8b/711cc9e2df683257852a72ad4453c4fbddb2c3": "4ac2c9c8783f8b6eac0e2997fe08baf4",
".git/objects/8e/0c3e4b9992c6ba5352118c73a15f39cfa2b4e3": "8f6123b11e6eb1fcdb8d23ed945c2824",
".git/objects/25/cb3d0d9a5756c36b7c8e86d750617230a3c420": "5c4513c8c788ea3ceb242ed1364d98a0",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b693e9967f51d1894139158b790e6b31",
".git/logs/refs/heads/main": "56c031bb1dd61a8ff41d52a3290d7bf5",
".git/logs/refs/remotes/origin/main": "97a8fcff41814668365dfe1d2821e336",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/main": "6f27ef75f4b275b9b1112985165d8582",
".git/refs/remotes/origin/main": "6f27ef75f4b275b9b1112985165d8582",
".git/index": "9ff585076a3a2e7adc5e24410c753ebe",
".git/COMMIT_EDITMSG": "01eb2c11c2685e04a0e3b0556549b914",
"assets/AssetManifest.json": "1bf0dd4cee14de28303bad41c1f814fc",
"assets/NOTICES": "9d0a3dc1c0515c1154a5f74006511dca",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "073f397dcb48d0f39808c91c8d709e48",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "a9af5815fb01e2c80458b50868876a0e",
"assets/fonts/MaterialIcons-Regular.otf": "05e53411d5bf6c9443ad2d4e2487f495",
"assets/assets/images/my_img.png": "e7091b3d89c0c287045549beb258fdeb",
"assets/assets/images/backgrounds/home_bg.jpg": "7d4220c8c77c4ef6e160b598c5f7bcd0",
"assets/assets/rive/birb.riv": "517eb597a90d23b0062ce969aedbcc78",
"canvaskit/skwasm.js": "f17a293d422e2c0b3a04962e68236cc2",
"canvaskit/skwasm.js.symbols": "704e58848c3923c62346aa25cc091e4d",
"canvaskit/canvaskit.js.symbols": "365a61023a6b250a85ca34004d74d93c",
"canvaskit/skwasm.wasm": "7a244c780421b699564c472bb5c2d1f8",
"canvaskit/chromium/canvaskit.js.symbols": "67368b743632c7b0fe64794367a919de",
"canvaskit/chromium/canvaskit.js": "87325e67bf77a9b483250e1fb1b54677",
"canvaskit/chromium/canvaskit.wasm": "587c2a4cda1683993a8c6c0a8937e2c2",
"canvaskit/canvaskit.js": "5fda3f1af7d6433d53b24083e2219fa0",
"canvaskit/canvaskit.wasm": "26e956fbc7086cb361a9ff0df511a1c8",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
