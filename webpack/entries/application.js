const path = require("path");
const fs = require("fs");
const crypto = require("crypto");

const WorkboxPlugin = require("workbox-webpack-plugin");

const common = require("../config.common");
const config = require("../config");

const {
  ADDITIONAL_PRECACHE_MANIFEST_FILES,
  ENTRIES,
  ENTRY_NAMES,
  utils: { projectPath }
} = config;

const NAME = ENTRY_NAMES.APPLICATION;

const entry = common(NAME, ENTRIES[NAME]);

const additionalFiles = originalManifest => {
  const warnings = [];
  const manifest = originalManifest;

  ADDITIONAL_PRECACHE_MANIFEST_FILES.forEach(file => {
    try {
      const revision = crypto.createHash("sha256");
      const isIndexFile = file === "/";

      revision.update(
        !isIndexFile
          ? fs.readFileSync(path.join(projectPath, "public", file), "utf8")
          : new Date().valueOf().toString() + Math.random().toString(),
        "utf8"
      );
      manifest.push({
        url: isIndexFile ? file : `/${file}`,
        revision: revision.digest("hex")
      });
    } catch (error) {
      throw new Error(`Failure adding file to precache-manifest: ${error.message}`);
    }
  });

  return { manifest, warnings };
};

entry.optimization = {
  ...entry.optimization,
  splitChunks: {
    cacheGroups: {
      defaultVendors: {
        test: /[\\/]node_modules[\\/]/,
        name: "vendor",
        chunks: "all"
      }
    }
  }
};

entry.plugins.push(
  new WorkboxPlugin.InjectManifest({
    swDest: path.join(projectPath, "public/worker.js"),
    swSrc: path.join(projectPath, "app/javascript/worker.js"),
    exclude: [/\*.json$/],
    manifestTransforms: [additionalFiles],
    maximumFileSizeToCacheInBytes: 100 * 1024 * 1024
  })
);

module.exports = entry;
