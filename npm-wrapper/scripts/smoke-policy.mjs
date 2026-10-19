export function assertProvenanceResult(status, stdout, packageName, version) {
  if (status !== 0 || typeof stdout !== 'string' || !stdout.trim()) {
    throw new Error(`${packageName}@${version} has no verified registry provenance metadata`);
  }
  return true;
}
