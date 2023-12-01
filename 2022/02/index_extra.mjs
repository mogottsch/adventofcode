import { promises as fs } from "fs";

const choiceScoreMap = {
  rock: 1,
  paper: 2,
  scissors: 3,
};

const outcomeScoreMap = {
  lose: 0,
  draw: 3,
  win: 6,
};

const opponentChoiceMap = {
  A: "rock",
  B: "paper",
  C: "scissors",
};

const desiredOutcomeMap = {
  X: "lose",
  Y: "draw",
  Z: "win",
};

const gameWinMap = {
  rock: "scissors",
  paper: "rock",
  scissors: "paper",
};

const gameLoseMap = {
  rock: "paper",
  paper: "scissors",
  scissors: "rock",
};

function calculateDesiredPlayerChoice(desiredOutcome, opponentChoice) {
  if (desiredOutcome === "win") {
    return gameLoseMap[opponentChoice];
  }

  if (desiredOutcome === "lose") {
    return gameWinMap[opponentChoice];
  }

  return opponentChoice;
}

const inputPath = "./input.txt";
const input = await fs.readFile(inputPath, "utf-8");

const lines = input.split("\n").slice(0, -1);

let totalScore = 0;

for (const line of lines) {
  const choices = line.split(" ");
  const opponentChoice = opponentChoiceMap[choices[0]];
  const outcome = desiredOutcomeMap[choices[1]];
  const playerChoice = calculateDesiredPlayerChoice(outcome, opponentChoice);

  const outcomeScore = outcomeScoreMap[outcome];
  const choiceScore = choiceScoreMap[playerChoice];

  const resultScore = outcomeScore + choiceScore;

  // console.log({ opponentChoice, outcome, playerChoice, resultScore });
  totalScore += resultScore;
}

console.log(totalScore);
