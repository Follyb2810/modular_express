import express, { Application, Response, Request, NextFunction } from "express";
const port = process.env.PORT || 8080;
const app: Application = express();
import morgan from "morgan";

app.use(morgan("tiny"));
app.disable("x-powered-by");
app.set("trust proxy", true);
app.use(express.json());


app.get("/", (req: Request, res: Response) => {
res.send('hello starter')
});

app.listen(port, () => console.log("we are on port " + port));