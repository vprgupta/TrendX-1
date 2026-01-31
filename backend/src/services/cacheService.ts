// Minimal cache service implementation
export const get = async (key: string) => {
  return null;
};

export const set = async (key: string, value: any, ttl?: number) => {
  return true;
};

export const del = async (key: string) => {
  return true;
};