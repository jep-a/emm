function ChatChannel:AddInvite(ply, timeout)
    self.invites[ply] = true
    if(timeout) then 
        timer.Create("chatinvite_ch"..self.id.."_pl"..ply.UserID(), timeout, 1, function()
           self.invites[ply] = nil 
        end)
    end
end

function ChatChannel:RemoveInvite(ply)
    if not timer.Exists(timer_id) then return end

    timer.Remove("chatinvite_ch"..self.id.."_pl"..ply.UserID())
    self.invites[ply] = nil
end

function ChatChannel:HasInvite(ply)
    return self.invites[ply] == true
end