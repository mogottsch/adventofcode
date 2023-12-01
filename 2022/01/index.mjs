import { readFileSync } from "fs";

const data = readFileSync("./01/input.txt", "utf8");

const lines = data.split("\n");

const bags = [];
let currentBag = [];

for (const line of lines) {
  if (line === "") {
    bags.push(currentBag);
    currentBag = [];
    continue;
  }
  currentBag.push(parseInt(line));
}

const caloriesPerElf = [];

for (const bag of bags) {
  const totalCalories = bag.reduce((prev, curr) => prev + curr);
  caloriesPerElf.push(totalCalories);
}

caloriesPerElf.sort((a, b) => b - a);

const nFirst = 3;

const totalCaloriesOfNFirst = caloriesPerElf
  .slice(0, nFirst)
  .reduce((prev, curr) => prev + curr);

console.log(totalCaloriesOfNFirst);
