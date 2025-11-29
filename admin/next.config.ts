import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  output: 'standalone', // Required for Cloud Run
  outputFileTracingRoot: path.join(__dirname, '../'),
  experimental: {
    serverActions: {
      bodySizeLimit: '2mb',
    },
  },
  // Disable static optimization for all routes (we're using SSR with Cloud Run)
  generateBuildId: async () => {
    return 'build-' + Date.now()
  },
};

export default nextConfig;
