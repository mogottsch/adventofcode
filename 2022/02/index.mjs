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

const playerChoiceMap = {
  Y: "paper",
  X: "rock",
  Z: "scissors",
};

const gameWinMap = {
  rock: "scissors",
  paper: "rock",
  scissors: "paper",
};

function calculateOutcome(opponentChoice, playerChoice) {
  if (opponentChoice === playerChoice) {
    return "draw";
  }

  if (gameWinMap[playerChoice] === opponentChoice) {
    return "win";
  }

  return "lose";
}

const inputPath = "./input.txt";
const input = await fs.readFile(inputPath, "utf-8");

const lines = input.split("\n").slice(0, -1);

let totalScore = 0;

for (const line of lines) {
  const choices = line.split(" ");
  const opponentChoice = opponentChoiceMap[choices[0]];
  const playerChoice = playerChoiceMap[choices[1]];

  const outcome = calculateOutcome(opponentChoice, playerChoice);
  const outcomeScore = outcomeScoreMap[outcome];
  const choiceScore = choiceScoreMap[playerChoice];

  const resultScore = outcomeScore + choiceScore;
  // console.log({ resultScore, outcome, opponentChoice, playerChoice });
  totalScore += resultScore;
}

console.log(totalScore);
