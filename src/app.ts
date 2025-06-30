import dotenv from "dotenv";
dotenv.config();
import express, { Application, Response, Request } from "express";
import cors from "cors";
import morgan from "morgan";
import { auth } from "./middleware/authentication";

const port = process.env.PORT || 8000;
const app: Application = express();

const corsConfig = {
  origin: "http://localhost:5173",
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
};

app.use(cors(corsConfig));
app.use(morgan("tiny"));
app.disable("x-powered-by");
app.set("trust proxy", true);
app.use(express.json());

app.get("/", (req: Request, res: Response) => {
  res.send("hello starter");
});

const document = ["a", "b", "c"];
app.get("/document", auth, (req: Request, res: Response) => {
  res.status(200).send(document);
});

app.listen(port, () => console.log("we are on port " + port));
