declare module 'express-serve-static-core' {
  interface Request {
    user?: {
      uid: string;
      email: string | undefined;
      role: 'nurse' | 'doctor' | 'admin';
      assignedRoom?: 'red' | 'yellow' | 'green' | 'black';
    };
  }
}
