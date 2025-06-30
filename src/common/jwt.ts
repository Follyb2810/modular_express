import { sign, verify, Secret, SignOptions } from "jsonwebtoken";

interface JwtPayload {
  id: string;
  // email: string;
  roles: string[];
}

class JwtService {
  private static secret: Secret | null = null;

  private constructor() {}

  private static getSecret(): Secret {
    if (!this.secret) {
      let rawKey = process.env.KeyCloak_Pub;

      if (!rawKey) {
        throw new Error(
          "KeyCloak_Pub is not defined in environment variables."
        );
      }

      if (!rawKey.startsWith("-----BEGIN PUBLIC KEY-----")) {
        rawKey = `-----BEGIN PUBLIC KEY-----\n${rawKey}\n-----END PUBLIC KEY-----`;
      }

      this.secret = rawKey;
    }

    return this.secret;
  }
  static signToken(
    payload: Record<string, any>,
    expiresIn: SignOptions["expiresIn"] = "1h"
  ): string {
    try {
      return sign(payload, this.getSecret(), { expiresIn, algorithm: "RS256" });
    } catch (error) {
      console.error("Error signing token:", error);
      throw error;
    }
  }
  static verifyToken<T = JwtPayload>(token: string): T {
    try {
      return verify(token, this.getSecret(), { algorithms: ["RS256"] }) as T;
    } catch (error) {
      console.error("Error verifying token:", error);
      throw error;
    }
  }

  // static verifyToken<T = JwtPayload>(token: string): T {
  //   try {
  //     return verify(token, this.getSecret(), { algorithms: ["RS256"] }) as T;
  //   } catch (error) {
  //     console.error("Error verifying token:", error);
  //     throw error;
  //   }
  // }
}

export default JwtService;
