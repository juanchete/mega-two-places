// Reads a Claude Code stream-json transcript and pulls out the job tool calls
// and the last `submit` reply exactly as the tool returned it.
// Usage: node worker/extract.mjs out/<job>.jsonl > out/<job>.result.json
import { readFileSync } from "node:fs";

const lines = readFileSync(process.argv[2], "utf8").split("\n").filter(Boolean);
const calls = new Map(); // tool_use_id -> { name, input }
const steps = [];
let finalLine = "";
let tools = [];
let mcpServers = [];

for (const line of lines) {
  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    continue;
  }
  if (msg.type === "system" && msg.subtype === "init") {
    tools = msg.tools ?? [];
    mcpServers = msg.mcp_servers ?? [];
  }
  const content = msg.message?.content;
  if (!Array.isArray(content)) {
    if (msg.type === "result") finalLine = String(msg.result ?? "").trim().split("\n").pop();
    continue;
  }
  for (const part of content) {
    if (part.type === "tool_use") calls.set(part.id, { name: part.name, input: part.input });
    if (part.type === "tool_result") {
      const call = calls.get(part.tool_use_id) ?? { name: "?", input: null };
      const text = Array.isArray(part.content)
        ? part.content.map((c) => (c.type === "text" ? c.text : `[${c.type}]`)).join("\n")
        : String(part.content ?? "");
      steps.push({ tool: call.name, input: call.input, isError: Boolean(part.is_error), reply: text });
    }
  }
}

const submits = steps.filter((s) => s.tool === "mcp__job__submit");
process.stdout.write(
  JSON.stringify(
    {
      job: process.argv[2].split("/").pop().replace(/\.jsonl$/, ""),
      mcpServers,
      jobTools: tools.filter((t) => t.startsWith("mcp__")),
      steps,
      submitCalls: submits.length,
      lastSubmit: submits.at(-1) ?? null,
      finalLine,
    },
    null,
    2,
  ) + "\n",
);
