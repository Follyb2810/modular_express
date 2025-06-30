import { NextFunction, Request, Response } from "express";
import JwtService from "../common/jwt";
import { JsonWebTokenError, TokenExpiredError } from "jsonwebtoken";

export interface AuthRequest extends Request {
  _id?: string;
  roles?: string[];
  cacheKey?: string;
  email?: string;
}

export const auth = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization?.replace("Bearer ", "");
    if (!token) {
      res.status(401).send({
        status: 401,
        message: "Access Token not found!",
        data: null,
      });
      return;
    }
    console.log({ token });

    const decode = JwtService.verifyToken<KeycloakJwtPayload>(token);
    if (!decode.email) {
      res.status(403).json({ message: "Invalid token structure" });
      return;
    }

    // console.log(decode);
    // if (!decode || !decode.id || !decode.roles) {
    //   res.status(403).json({ message: "Invalid token structure" });
    //   return;
    // }
    // console.log(decode);
    // req._id = decode.id;
    // req.roles = decode.roles;
    req.email = decode.email;

    next();
  } catch (error) {
    if (error instanceof TokenExpiredError) {
      res.status(401).json({ message: "Token expired" });
    } else if (error instanceof JsonWebTokenError) {
      res.status(401).json({ message: "Invalid token" });
    } else {
      console.error("Unexpected token error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  }
};
export interface KeycloakJwtPayload {
  exp: number;
  iat: number;
  auth_time: number;
  jti: string;
  iss: string;
  aud: string | string[];
  sub: string;
  typ: string;
  azp: string;
  sid: string;
  acr: string;
  scope?: string;
  email_verified: boolean;
  name: string;
  preferred_username: string;
  given_name: string;
  family_name: string;
  email: string;
  "allowed-origins"?: string[];
  realm_access?: {
    roles: string[];
  };
  resource_access?: {
    [resource: string]: {
      roles: string[];
    };
  };
}
