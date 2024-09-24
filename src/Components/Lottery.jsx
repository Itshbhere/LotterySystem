import React, { useState } from "react";

const LotteryButton = () => {
  const [message, setMessage] = useState("");

  const handleClick = () => {
    setMessage("Button Clicked!");
  };

  return (
    <div>
      <button onClick={handleClick}>Click Me</button>
      {message && <p>{message}</p>}
    </div>
  );
};

export default LotteryButton;
